# DevOps 2018 Exam

## Git Repos

[Infrastructure Repository](https://github.com/findus1994/DevOpsInfra2018)

[Application Repository](https://github.com/findus1994/DevOps2018)

## Deployment

1. Git Clone
    1. Fork both repositories linked above.
    2. Download the two forked repositories to your computer.

2. RSA Keys
    1. Now you need to create RSA keys for both git repos. 
    Open a terminal window and run this command to generate RSA keys: `ssh-keygen`. 
    You will be promted to write a filename, write the following: `deploy-key-app`, 
    leave the other fields blank.
    2. Run the same command as in the previous step but with a different filename: `deploy-key-infra`.
    3. Now use public keys as deployment keys online in the github repos.

3. Credentials
    1. Now Open the Infrastructure repository that you have downloaded. 
    In the project root directory rename the `credentials_example.yml`to `credentials.yml`.
    2. In the `credentials.yml file, replace all the credentials to your own, except for: logz_io_token.
        1. Replace the word `pokemon` with a name you choose, 
        in the heroku_app_name field in `credentials.yml` and in [variables.tf](./terraform/variables.tf).
        
    3. In the [provider_heroku.tf](./terraform/provider_heroku.tf) insert your heroku email.
    4. In the [statuscake.tf](./terraform/statuscake.tf) insert your statuscace username.
    5. Open the [pipeline.yml](./concourse/pipeline.yml) and replace the git repo uri´s to your forked repo-uri´s.

4. Start Docker and concourse
    1. After all this setup remember to push your changes to your repo.
    2. I assume you have concourse downloaded and the fly CLI installed, now you
    should run `docker-compose up -d`.
    
5. Start Fly/Concourse 
    1. Open a terminal and navigate to the Infra repository folder.
    2. Run this command: `fly -t pgr301 login --concourse-url http://127.0.0.1:8080;`
    3. Then this: `fly -t pgr301 sp -p exam-infra -c concourse/pipeline.yml -l credentials.yml`
        1. Open concourse by clicking on the link provided in the terminal.
        
    4. Then run this: `fly -t pgr301 unpause-pipeline -p exam-infra`
    
6. Start Build/Deploy
    1. Navigate to the web browser and the concourse view
    2. Click on the `Infra`-job and then trigger it.
    3. The `Build`-job should start by it self.
    4. You will now see `Build` and `Infra` running.
    5. After they are done `Deploy` and `deploy-heroku-config-vars`should be automatically triggered.
        1. This means that The infrastructure in Heroku is created, and The application is successfully built. 
        Docker image is also deployed to heroku.
  
    6. After `Deploy` and `deploy-heroku-config-vars` is done. 
        1. The application is now published and the hosted graphite enviornemt variables is added.

7. Enable Hosted Graphite
    1. Now Open Heroku and navigate to the newly created pipeline. 
    In here you will see 3 apps: Ci, Staging and Production.
        1. On each of the apps click on the Installed add on; Hosted Graphite, and copy the graphite url. 
        Then paste this in their respective variable in the `credentials.yml` file.
    
    2. Now run the command as described in task 5 again.
    3. Trigger `Infra` once more to make use of the new Graphite variables.
8. Access the application
    1. Access the application by hitting `Open App` on the `Ci application inside Heroku.`
        1. Remember to add `api/pokemon` to the url after hitting `Open App`. 
    2. You will as well be able to see all the apps in the pipeline in your StatusCake page.
        1. Here you can monitor your applications.
    

### Tasks Done

- [x] Basic Pipeline
- [x] Docker
- [x] Surveillance, Alert and Metrics
- [x] Terraform bug fixed in Infrastructure
- [x] Cached maven dependencies

#### Basic Pipeline
Here I have created a pipeline with in total 4 jobs.

One responsible for createing the infrastructure, one for building the application and creating docker images.
Another for Publishing the newly created docker image, and one last to insert Graphite environment variables.


#### Docker
I Have used Docker in this exam. It has been used to create Docker images, 
these have then been pushed to Heroku Container Registry. And from there Pushed to the Ci application/environment.


#### Surveillance, Alert and Metrics

I have made use of three types of metrics:

- Meter
- Counter
- Timer

StatusCake is also implemented to listen to all three applications in the pipeline.

Graphite is implemented in all three applications as well.

#### Bonus

As a bonus I have implemented a fix for the problem where Infrastructure will fail the second time It runs, 
this because git is complaining due to no changes to commit. This fix can be found in [terraform.sh](./concourse/terraform/terraform.sh).

I have as well implemented caching for maven dependencies so the second time and beyond a build is triggered it won´t donwload the whole internet again.


### Application API

For the application I have created a Pokemon API in Kotlin.

This API support the following endpoints and HTTP methods:

| HTTP Method     | URL                      | Metric implemented  |
| :-------------: |:-----------------------: | :-----:|
| [GET]           | /api/pokemon             | true  |
| [GET]           | /api/pokemon{id}         | true  |
| [GET]           | /api/pokemon?type=Fire   | true  |
| [POST]          | /api/pokemon             | true  |
| [PATCH]         | /api/pokemon/{id}        | false |
| [PUT]           | /api/pokemon/{id}        | false |
| [DELETE]        | /api/pokemon/{id}        | false |



### Improvements

For further development I Could have devided the jobs into smaller tasks.

I could also have tried to use Google Cloud or AWS instead of Heroku. Especially because
Heroku has alot of limitations. 

Further I would have created logs with Logz.io and made an even better API for testing with smoke tests etc.

### References 

[Metrics Tutorial](https://metrics.dropwizard.io/4.0.0/manual/core.html#timers)

[Maven Dependencies Caching](http://www.java-allandsundry.com/2017/08/concourse-caching-for-java-maven-and.html)

[Shell Script Git Diff](https://github.com/skratchdot/Git-Diff-Build-Script)