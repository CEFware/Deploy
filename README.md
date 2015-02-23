# Deploy
Deploy fresh CEF server stacks, subdomains and Apps
meteor-deploy.sh
Script that handles deploying meteor apps from git repo, creating server for meteor , and handle nginx vhost


# Quick Start

1. SETUP SERVER: (if the server is completely fresh) <br>
    ```sh meteor-deploy.sh setup server ```

    Installs node.js, mongodb,nginx, meteor distribution etc
2. Setup  project: (If you are deploying for the first time)<br>
   ```sh meteor-deploy.sh setup project ```

   Setup a project by cloning to git repo according to the name of repo in the git.

3. Setup NGINX : (if you are pointing the domain for the first time)<br>
   ``` sh meteor-deploy.sh setup nginx ```

   creates virtual Host file and points to the port no we assigned with the domain we provided

4. Deploy <br>
    ``` sh meteor-deploy.sh deploy ```

   Pulls latest code from the repo and bundles it and start the app forever.

 cool, We have hosted our app into the server now we will make changes obviously we developers do for further deploying you dont
 need to go through setup process just execute step 4 and we will have recent app deployed by pulling from the git repo.


# Configuration
 There are few variables you need to assign before going to this process
 1. IP or URL of the server you want to deploy to <br>
   ``` APP_HOST= Your host // this is the address where you want to deploy the meteor apps ```

 2.USERNAME OF THE SERVER you are trying to deploy in <br>
   ``` ROOT="root" ```

 3. What's your project's Git repo? <br>
    ``` GIT_URL="address of the git repo" ```
   Note: if you are in private repo and still want to connect git as https then the URL must go like this

    ```  GIT_URL="https://username:password@github.com/path/to/repo"  ```

 4. Name of App: <br>
   ``` APP_NAME="App name"  ```
    Note: Must be same as git repo name



 5. URL OF THE APP YOU WANT TO HOST <br>
    ``` ROOT_URL='expample.com' or 'test.example.com' ```

    Note: load balancer setup coming soon

 6. Mongodb Url <br>
   ```  MONGO_URL=url of the mongo db ```

 7. PORT Number on which you want the apps to run <br>
     ``` PORT= portno //eg 3000 ```

 8. If you have an external service, such as Google SMTP, set this <br>
    ```  MAIL_URL=smtp://USERNAME:PASSWORD@smtp.googlemail.com:465 ```

 #Future:
  1. create dynamic subdomain with custom name. <br>
  2. Informative help option in the script command