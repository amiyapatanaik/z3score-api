## Major Update: API now supports Z3Score V2 (NEO)
Z3Score version 2 is built from the ground up and is trained and tested on massive datasets (over 30,000 hours of data). It shows a 35 to 40% reduction in error rate in some datasets. The Z3Score API remains the same, but to utilize this new scorer simply use the new CFS V2 format to convert your raw PSG data. 

CFS V1 will automatically use the Z3Score V1 sleep scorer
CFS V2 will automatically use the Z3Score V2 (NEO) sleep scorer

# Z3Score Sleep Scoring API
Z3score provides an easy to use RESTful API to carry out sleep scoring. Associated paper will be made available soon. Sample code in MATLAB and Python are included. You will need an API key to be able to access the server. To request an API key, send in your requests to: contact@z3score.com 

The included sample code requires cfslib to be able to create and stream CFS files. Download cfslib from:
- Python: https://github.com/neurobittechnologies/pycfslib or do pip install pycfslib. In addition the sample python code requires pyedflib to be able to read the sample EDF file included here. Get pyedflib at: https://github.com/holgern/pyedflib or do pip install pyedflib
- MATLAB: https://github.com/neurobittechnologies/cfslib-MATLAB 

### GUI for the API
You can use GUI based on FASST to quickly do scoring via an user interface. The GUI is Matlab based and can be downloaded from here: https://github.com/neurobittechnologies/FASST-Z3Score  

### Sample Run
Clone/Download this package. In sampleAPI.py enter your email address and API key in the appropriate location.
``` python
serverURL = 'https://z3score.com/api/v1'
email = 'email@domain.com'
key = 'yourAPIKey'
```
Now run:
``` shell
python sampleAPI.py
```
Sample Output:
``` shell
License valid till: 28-February-2017 UTC.
API Call limit (hourly): 300, Epoch limit (daily): 100000
Here are the channel labels:
1. C3-M2
2. C4-M1
3. O1-M2
4. O2-M1
5. F3-M2
6. F4-M1
7. Chin1-Chin2
8. EKG
9. PG1-M2
10. PG2-M1
Enter channel C3-A1 number: 1
Enter channel C4-A2 number: 2
Enter channel EoGleft-A1 number: 9
Enter channel EoGright-A2 number: 10
Enter channel bipolar EMG number: 7
Reading EDF file...
Time taken: 2.432
Converting to CFS and saving in test.cfs...
Time taken: 4.365
Now scoring
Time taken: 12.950
Auto scoring agreement with expert scorer: 86.86%, Kappa: 0.831
Done.
```
You can try the MATLAB sample similarly. 

**Score CFS file/stream**
----
 Sleep scores CFS file.

* **URL**

  https://z3score.com/api/v1/score

* **Method:**

  `POST`
  
*  **URL Params**

   **Required:**
 
   `email=[string]`<br />
   `key=[string]`<br />
   `file=[multipart/form-data]`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ status : 1 or 0, message : N epochs x 2 array, calls_left = C, epochs_left = E}` <br />
    status is 1 for success or 0 for failure.<br />
    Sleep stages are encoded as: Wake - 0, Stage1 - 1, Stage2 - 2, Stage3 - 3, REM - 5.<br />
    Confidence varies between 0 and 10. 0 very low confidence, 10 very high confidence.<br />
    calls_left is the number of hourly API calls left, returned only if successful.<br />
    epochs_left is the number of daily epochs left, returned only if successful.<br />
 

* **Sample Call using CURL:**

  ```shell
    curl  -F file=@cfsfile.cfs -F email=email@domain.com -F key=yourAPIkey https://z3score.com/api/v1/score
  ```
  Response (sample cfs had 6 epochs):
  ```shell
  {
  "calls_left": 18, 
  "epochs_left": 57031, 
  "message": [ [0.0,8.34], [0.0,10.0], [0.0,10.0], [1.0,10.0], [1.0,10.0], [2.0,10.0]  ],
  "status": 1
 }
```
  
  **Check API key**
----
 Validate API key and also check API call limits. 

* **URL**

  https://z3score.com/api/v1/check

* **Method:**

  `POST` or `GET`
  
*  **URL Params**

   **Required:**
 
   `email=[string]`<br />
   `key=[string]`<br />

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ status : 1 or 0, message : validity of the license or error message, call_limit = C, epoch_limit = E}` <br />
    status is 1 for success or 0 for failure.<br />
    call_limit is the allowed number of API calls in any given hour, returned only if successful.<br />
    epoch_limit is the allowed number of epochs that can be scored in any given 24 hour period, returned only if successful.<br />
    

* **Sample Call using CURL:**

   ```shell
    curl -F email=email@domain.com -F key=yourAPIkey https://z3score.com/api/v1/check
  ```
  Response:
  ```shell
  {
  "call_limit": 20, 
  "epoch_limit": 60000, 
  "message": "License valid till: 28-February-2017 UTC.", 
  "status": 1
   }
```
