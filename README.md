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
    calls_left is the number of hourly API calls left, returned only if successfully.<br />
    epochs_left is the number of daily epochs left, returned only if successfully.<br />
 

* **Sample Call:**

  ```matlab
    try
    response = loadjson(urlreadpost('http://z3score.com/api/v1/check', ... 
        {'email',email,'key',key,'file',stream}));
	catch
    	disp('Server is unreachable');
    	return
	end
  ```
  
  **Check API key**
----
 Validate API key.

* **URL**

  https://z3score.com/api/v1/check

* **Method:**

  `POST`
  
*  **URL Params**

   **Required:**
 
   `email=[string]`<br />
   `key=[string]`<br />

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ status : 1 or 0, message : validity of the license or error message}` <br />
    status is 1 for success or 0 for failure.<br />
    

* **Sample Call:**

  ```matlab
    try
    response = loadjson(urlreadpost('http://z3score.com/api/v1/check',...
                                        {'email',email,'key',key}));
    catch
      disp('Server is unreachable');
      return
    end
  ```
