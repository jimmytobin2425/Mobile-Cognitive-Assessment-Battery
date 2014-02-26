import cgi
import os
import urllib
import string
import random
from datetime import datetime
import time
import logging

from google.appengine.api import memcache
from google.appengine.api import users
from google.appengine.ext import ndb

import webapp2
import jinja2

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)


DEFAULT_STUDY_NAME = 'default_study'


test_abbreviations = ["mt","swi","nb","sr"]
tests = ["Multitasking","Switching","N-Back","Self-Rating"]

#Error messages patients could see:
error_messages = {
    "url":'The url you entered does not exist. Please check the link you were given.', 
    "no patient id":"Patient does not exist in the database", 
    "no test id":"No test with that id",
    "no id entered":"No id entered",
    "Id not a number":"Id must be a number",
    "Patient already exists":"A patient with that id already exists.",
    "no tests":"No tests were selected"
}

##Database Entities

class TestData(ndb.Model):
    testName = ndb.StringProperty()
    data = ndb.StringProperty(indexed=False)

#A patient is created by the admin. The patient has an id which is only visible to the admin and a 'url',
#which will be the patient's unique way to access the site. 
class Patient(ndb.Model):
    """A patient that will take the test, this includes url and data."""
    id = ndb.IntegerProperty()
    pastBatteries = ndb.StructuredProperty(TestData, repeated = True)

class Battery(ndb.Model):
    url = ndb.StringProperty()
    dateCreated = ndb.DateTimeProperty(auto_now_add=True)
    dateString = ndb.StringProperty()
    testData = ndb.StructuredProperty(TestData, repeated=True)

def study_key(study_name=DEFAULT_STUDY_NAME):
    """Constructs a Datastore key for a Guestbook entity with guestbook_name."""
    return ndb.Key('Study', study_name)




##RequestHandlers

class MainPage(webapp2.RequestHandler):

    def get(self):
        curBattery=None
        url = self.request.get('id')
        print "Url is ",url
        if not url:
            self.redirect('/info')
            return
        battery_query = Battery.query(Battery.url==url)
        if battery_query.fetch():
            curBattery = battery_query.fetch()[0]
        else:
             self.redirect('/error?'+urllib.urlencode({'msg':'url'}))
             return

        curTest = None

        for test in curBattery.testData:
            if not test.data:
                curTest=test

        if not curTest:
            self.redirect('/complete?'+urllib.urlencode({'msg':'test finished'}))

        template_values = {
            'battery': curBattery
        }


        template = JINJA_ENVIRONMENT.get_template('static/test.html')
        self.response.write(template.render(template_values))

    

class ErrorPage(webapp2.RequestHandler):

    def get(self):
        error=self.request.get('msg')


        template_values = {
            'error': error_messages[error],
        }

        template = JINJA_ENVIRONMENT.get_template('static/error.html')
        self.response.write(template.render(template_values))


class InfoPage(webapp2.RequestHandler):

    def get(self):
        template = JINJA_ENVIRONMENT.get_template('static/info.html')
        self.response.write(template.render())

class Admin(webapp2.RequestHandler):
    #TODO add permissions
    def get(self):
        #Template Variables
        curPatient=None;
        pastBatteries=None;
        curBatt = None;
        error_message=None;
        pastBatteries_list=None;
        patients_list=None;

        study_name = self.request.get('study_name',DEFAULT_STUDY_NAME)
        
        error = self.request.get('error')
        
        if error: error_message = error_messages.get(error)
        patientID = self.request.get('patient')
        battery_url = self.request.get('battery')
        user = users.get_current_user()

        patients_list, patients_dict = self.get_patients(study_name)

        if patientID:
            curPatient = patients_dict.get(int(patientID))
            if not curPatient:
                error="no patient id"
                self.redirect('/admin?'+urllib.urlencode({'error':error})+'#errorMod')
                return
            pastBatteries_list, pastBatteries_dict = self.get_batteries(patientID, curPatient)
            if battery_url:
                curBatt = pastBatteries_dict.get(battery_url)
                if not curBatt:
                    error="no test id"
                    self.redirect('/admin?'+urllib.urlencode({'error':error, 'patient':patientID})+'#errorMod')
                    return

        template_values = {
            'patients': patients_list,
            'error_message': error_message,
            'curPatient': curPatient,
            'pastBatteries': pastBatteries_list,
            'curBattery': curBatt
        }

        template = JINJA_ENVIRONMENT.get_template('static/admin.html')
        self.response.write(template.render(template_values))


    def batteriesToDict(self, pastBatteries):
        batts = {}
        for battery in pastBatteries:
            batts[battery.url] = battery
        return batts

    def patientsToDict(self, patients):
        pats = {}
        for patient in patients:
            pats[patient.id] = patient
        return pats

    def get_patients(self, study_name=DEFAULT_STUDY_NAME):
        patients_list = memcache.get('%s:patients_list' % study_name)
        patients_dict = memcache.get('%s:patients_dict' % study_name)
        if patients_list and patients_dict is not None:
            print(patients_list, patients_dict)
            return patients_list, patients_dict
        else:
            patients_list = Patient.query(ancestor=study_key(study_name)).order(Patient.id).fetch()
            patients_dict = self.patientsToDict(patients_list)
            if not memcache.add('%s:patients_list' % study_name, patients_list):
                logging.error('Memcache set failed.')
            if not memcache.add('%s:patients_dict' % study_name, patients_dict):
                logging.error('Memcache set failed.')
        return patients_list, patients_dict

    def get_batteries(self, patient_id, curPatient):
        pastBatteries_list=memcache.get('%s:batteries_list' % patient_id)
        pastBatteries_dict=memcache.get('%s:batteries_dict' % patient_id)
        if pastBatteries_list and pastBatteries_dict is not None:
            return pastBatteries_list, pastBatteries_dict 
        else:
            pastBatteries_dict =  Battery.query(ancestor=curPatient.key).order(-Battery.dateCreated).fetch()
            pastBatteries_dict = self.batteriesToDict(pastBatteries_dict)
            if not memcache.add('%s:batteries_dict' % patient_id, pastBatteries_dict):
                logging.error('Memcache set failed.')
            if not memcache.add('%s:batteries_list' % patient_id, pastBatteries_list):
                logging.error('Memcache set failed')
        return pastBatteries_list, pastBatteries_dict

    

class AddPatient(webapp2.RequestHandler):
    def post(self):
        study_name = self.request.get('study_name',DEFAULT_STUDY_NAME)
        patients_list = memcache.get('%s:patients_list' % study_name)
        patients_dict = memcache.get('%s:patients_dict' % study_name)

        if not patients_dict and patients_list:
            patients_dict = {}
            patients_list = []

        patientID = self.request.get('patientID')
        if not patientID: 
            error="No id entered"
            self.redirect('/admin?'+urllib.urlencode({'error':error})+'#errorMod')
            return
        try:
            patientID = int(patientID)
        except ValueError:
            error="Id not a number"
            self.redirect('/admin?'+urllib.urlencode({'error':error})+'#errorMod')
            return
        if patients_dict.get(patientID):
            error="Patient already exists"
            self.redirect('/admin?'+urllib.urlencode({'error':error})+'#errorMod')
            return
        
        self.addPatient(patientID, study_name, patients_dict, patients_list)

        self.redirect('/admin?'+urllib.urlencode({'patient':patientID}))

    def addPatient(self, patientID, study_name, patients_dict, patients_list):
        newPatient = Patient(parent=study_key(study_name), id=patientID)
        newPatient.put()
        patients_dict[str(patientID)] = newPatient
        patients_list.append(newPatient)
        patients_list_sorted = sorted(patients_list, key=lambda pat:pat.id)
        memcache.set('%s:patients_list' % study_name, patients_list_sorted)
        memcache.set('%s:patients_dict' % study_name, patients_dict)





class AddBattery(webapp2.RequestHandler):
    def post(self):
        #get current patient
        study_name = self.request.get('study_name',DEFAULT_STUDY_NAME)
        patientID = self.request.get('id')
        curPatient = self.get_curPatient(patientID, study_name)
        if not curPatient:
            print "can't find patient"
        else:
            print curPatient

        onTests = []
        for test in test_abbreviations:
            testStatus = self.request.get(test)
            if testStatus == 'on':
                onTests.append(tests[test_abbreviations.index(test)])
        
        
        newURL = self.createRandURL()

        #check if tests were chosen
        if not onTests:
            error="no tests"
            self.redirect('/admin?'+urllib.urlencode({'error':error,'patient':curPatient.id})+'#errorMod')
            return
        td = []
        for t in onTests:
            td.append(TestData(testName=t))
        date = datetime.now()
        self.addBattery(curPatient, date, newURL, td)
        self.redirect("/admin?"+urllib.urlencode({"patient":patientID,"battery":newURL}))

    def addBattery(self, patient, date, url, testData):
        newBattery = Battery(parent=patient.key, dateString=date.strftime("%Y-%m-%d %H:%M:%S"), url=url, testData=testData)
        print newBattery
        newBattery.put()
        batteries_dict =  memcache.get('%s:batteries_dict' % patient.id)
        batteries_list = memcache.get('%s:batteries_list' % patient.id)
        if not batteries_list and not batteries_dict:
            batteries_dict={}
            batteries_list=[]
        batteries_dict[url] = newBattery
        batteries_list.append(newBattery)
        sorted_batt_list = sorted(batteries_list, key=lambda bat: bat.dateString, reverse=True)
        memcache.set('%s:batteries_list' % patient.id, sorted_batt_list)
        memcache.set('%s:batteries_dict' % patient.id, batteries_dict)


    def get_curPatient(self, patientID, study_name):
        patients = memcache.get('%s:patients_dict' % study_name)
        if not patients:
            logging.error('Memcache set failed.')
            return None
        return patients[patientID]


    def createRandURL(self):
        size=6
        chars=string.ascii_uppercase + string.digits
        newURL = ''.join(random.choice(chars) for x in range(size))
        #check there are no repeats
        while Battery.query(Battery.url==newURL).fetch():
            newURL = ''.join(random.choice(chars) for x in range(size))
        return newURL








app = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/info', InfoPage),
    ('/error', ErrorPage),
    ('/admin', Admin),
    ('/newPatient', AddPatient),
    ('/newTestBattery', AddBattery),
], debug=True)