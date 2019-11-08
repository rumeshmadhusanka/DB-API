# Software Engineering Project Back-end API
[![Build Status](https://travis-ci.org/rumeshmadhusanka/SE.svg?branch=master)](https://travis-ci.org/rumeshmadhusanka/SE)
###Deployment 
https://software-engi.herokuapp.com/

System Architecture Document
https://docs.google.com/document/d/1br3VXRLCZ9pewrxHVNTTnKmoyK74qNNXEE7DNkahrDU/edit
![alt text](public/images/DB%20schema%20design.png)
_GET customer/:id_

{
    "success": true,
    "error_code": "",
    "message": "Affected Rows: 1",
    "data": [
        {
            "id": 1,
            "first_name": "Kamal",
            "last_name": "Fernando",
            "email": "kamal@gmail.com",
            "contact_no": "0786564786"
        }
    ],
    "token": ""
}

_POST customer_

{
	"first_name":"Amal",
	"last_name":"Rathnayake",
	"email":"amal@gmail.com",
	"contact_no":"0786567654",
	"password":"uvh dvfvrtgbtgbhtbb hdbhb f"
}

_PUT customer/:id_

_DELETE customer/:id_

