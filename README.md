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
