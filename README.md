# Airline Reservation System REST API
Completed for the Database Systems module<br>
Swagger REST API:<br>
![logo](images/swagger1.png) 
<br>
![logo](images/grafana.png)

## MySQL
* Triggers
* Functions
* Views
* Stored procedures
* Indexing 
* Using transactions where necessary

## The API
* Node Express REST api
* Using promises
* API Documentation with `Swagger`(Open API 2.0)
* Centralized error handling
* Passwords hashing using `bcrypt`
* Authentication with jwt
* User input validation using `hapi/joi`
* Uses `promise-mysql` and connection pooling
* Load balancing using `pm2` process management
* `Grafana` for Realtime Report generation 


## Quick Start

- Import the sql file at **dbBackup** folder to your mysql server

- Add your database credentials to **db.conf.json**

- Run the project in dev mode with `nodemon`- ```> npm run dev``` **OR**  with node- ```> npm start```

- Install [Grafana](https://grafana.com/) and import the dashboards


## Install the dependencies
```
> npm install 
```

## Run in development
- Uses nodemon ```npm dev```

## Deploy
- Uses pm2 ```npm start```



## Collaborators

- [Rumesh Madhusanka](https://github.com/rumeshmadhusanka)

- [Kushan Chamindu](https://github.com/KushanChamindu)

- [Shashimal Senarath](https://github.com/shashimalcse)

- [Jayampathi Adhikari](https://github.com/jayampathiadhikari)
