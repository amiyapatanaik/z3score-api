#!/usr/bin/python
# Test script for Z3Score.com RESTful API
# For documentation pertaining to the API please visit
# https://github.com/amiyapatanaik/z3score-api
# This script demonstrates the basic functionalities of the Z3Score
# API. The API can be accessed from any language
# to know more see: https://en.wikipedia.org/wiki/Representational_state_transfer
# Patents pending (c)-2016 Amiya Patanaik amiyain@gmail.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# requires pycfslib and pyedflib, install using pip: 
# pip install pycfslib 
# pip install pyedflib

from pycfslib import save_stream_v2
import pyedflib
import numpy as np
import csv
from requests import post
from time import time
from sklearn.metrics import cohen_kappa_score

serverURL = 'https://z3score.com/api/v1'
email = 'email@domain.com'
key = 'yourKey'

# Check license validity
response = post(serverURL+'/check',data={'email':email, 'key':key})
if response.status_code != 200:
    print("ERROR communicating with server")
    exit(0)
data = response.json()
if data['status'] == 0:
    print("License check failed")
    print(data['message'])
    exit(0)

print(data['message'])
print('API Call limit (hourly): %d, Epoch limit (daily): %d\n' % (data['call_limit'], data['epoch_limit']))

path = 'test.edf'
edf_file = pyedflib.EdfReader(path)
labels = edf_file.getSignalLabels()
samples = edf_file.getNSamples()

print("Here are the channel labels:")
for idx, label in enumerate(labels):
    print('%d. %s' % (idx+1, label))

C3 = int(input("Enter channel C3-A1 number: ")) - 1
C4 = int(input("Enter channel C4-A2 number: ")) - 1
EL = int(input("Enter channel EoGleft-A1 number: ")) - 1
ER = int(input("Enter channel EoGright-A2 number: ")) - 1
EM = int(input("Enter channel bipolar EMG number: ")) - 1

fsampling = [edf_file.getSampleFrequency(C3), edf_file.getSampleFrequency(EL),
                     edf_file.getSampleFrequency(EM)]


print("Reading EDF file...")
start_time = time()
EEG_C3 = np.asarray(edf_file.readSignal(C3))
EEG_C4 = np.asarray(edf_file.readSignal(C4))
EOGL = np.asarray(edf_file.readSignal(EL))
EOGR = np.asarray(edf_file.readSignal(ER))
EMG = np.asarray(edf_file.readSignal(EM))
elapsed_time = time() - start_time
print("Time taken: %.3f" % elapsed_time)


print("Converting to CFS and saving in test.cfs...")
start_time = time()
stream = save_stream_v2('test.cfs', EEG_C3, EEG_C4, EOGL, EOGR, EMG, fsampling)
elapsed_time = time() - start_time
print("Time taken: %.3f" % elapsed_time)

print('Now scoring')
start_time = time()
files = {'file': ('stream.cfs', stream)}
response = post(serverURL+'/score', files=files, data={'email':email, 'key':key})
elapsed_time = time() - start_time
print("Time taken: %.3f" % elapsed_time)

if response.status_code != 200:
    print("ERROR communicating with server")
    exit(0)

data = response.json()
if data['status'] == 0:
    print("Scoring failed\n")
    print(data['message'])
    exit(0)

scores = np.array(data['message'])
num_epochs = len(scores)

with open('test_expert.csv', 'rt') as f:
    Yb = sum([[int(x) for x in rec] for rec in csv.reader(f, delimiter=',')], [])

accuracy = sum(scores[:,0]==Yb[0:num_epochs])*100.0/num_epochs

kappa = cohen_kappa_score(scores[:,0], Yb[0:num_epochs])

print("Auto scoring agreement with expert scorer: %.2f%%, Kappa: %.3f" % (accuracy, kappa))
print("Done.")
