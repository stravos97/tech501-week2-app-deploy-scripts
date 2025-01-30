# Comprehensive Guide to Deploying Applications and Databases on Azure Virtual Machines

## Introduction

This documentation covers everything from setting up your environment, managing Git repositories, deploying applications, configuring databases, setting up reverse proxies, and automating processes to ensure a smooth and efficient workflow.

---

## Table of Contents

- [Comprehensive Guide to Deploying Applications and Databases on Azure Virtual Machines](#comprehensive-guide-to-deploying-applications-and-databases-on-azure-virtual-machines)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Understanding Key Concepts](#understanding-key-concepts)
    - [Azure Virtual Machines](#azure-virtual-machines)
    - [Git and GitHub](#git-and-github)
    - [NGINX](#nginx)
    - [MongoDB](#mongodb)
    - [PM2](#pm2)
  - [Initial Setup](#initial-setup)
    - [Creating and Syncing a Git Repository](#creating-and-syncing-a-git-repository)
  - [Deploying the Application](#deploying-the-application)
    - [Creating the First VM for the Application](#creating-the-first-vm-for-the-application)
    - [Installing Necessary Software on the VM](#installing-necessary-software-on-the-vm)
  - [Configuring the Second VM](#configuring-the-second-vm)
    - [Creating the Second VM](#creating-the-second-vm)
    - [Setting Up Network Security Groups (NSGs)](#setting-up-network-security-groups-nsgs)
  - [Deploying the App Using SCP or Git Clone](#deploying-the-app-using-scp-or-git-clone)
    - [Git Clone Method](#git-clone-method)
  - [Setting Up the Database VM](#setting-up-the-database-vm)
    - [Creating the Database VM](#creating-the-database-vm)
    - [Installing and Configuring MongoDB](#installing-and-configuring-mongodb)
  - [Connecting the Application VM to the Database VM](#connecting-the-application-vm-to-the-database-vm)
  - [Setting Up a Reverse Proxy with NGINX](#setting-up-a-reverse-proxy-with-nginx)
  - [Managing the Application with PM2](#managing-the-application-with-pm2)
  - [Creating and Using VM Images](#creating-and-using-vm-images)
  - [Creating a Virtual Machine Scale Set](#creating-a-virtual-machine-scale-set)
    - [Why Use a Virtual Machine Scale Set?](#why-use-a-virtual-machine-scale-set)
    - [Parameters File Overview](#parameters-file-overview)
    - [Step-by-Step Guide to Creating the VM Scale Set](#step-by-step-guide-to-creating-the-vm-scale-set)
      - [Prerequisites](#prerequisites-1)
      - [1. Orchestration](#1-orchestration)
      - [2. Create a New Load Balancer](#2-create-a-new-load-balancer)
      - [3. Configure Network Interface Settings for the NIC](#3-configure-network-interface-settings-for-the-nic)
      - [4. Instance Details](#4-instance-details)
      - [5. Scaling Policy](#5-scaling-policy)
      - [6. Health](#6-health)
      - [7. Reimaging VM Scale Set Instances](#7-reimaging-vm-scale-set-instances)
      - [8. SSHing into the Load Balancer](#8-sshing-into-the-load-balancer)
      - [9. Deallocating and Reimaging Unhealthy Instances](#9-deallocating-and-reimaging-unhealthy-instances)
      - [10. How to Delete the VM Scale Set](#10-how-to-delete-the-vm-scale-set)
      - [11. How to Delete the Load Balancer](#11-how-to-delete-the-load-balancer)
    - [Verifying the VM Scale Set Deployment](#verifying-the-vm-scale-set-deployment)
    - [Summary of Key Configurations](#summary-of-key-configurations)
  - [Automating Deployment with User Data Scripts](#automating-deployment-with-user-data-scripts)
    - [Purpose](#purpose)
    - [Creating the `sparta-app-first-deploy.sh` Script](#creating-thesparta-app-first-deployshscript)
    - [Benefits of Automation Scripts](#benefits-of-automation-scripts)
  - [Best Practices for Deleting VMs](#best-practices-for-deleting-vms)
    - [Deletion Steps](#deletion-steps)
    - [Additional Tips](#additional-tips)
  - [Conclusion](#conclusion)

---

## Prerequisites

Before diving into the deployment process, ensure you have the following:

- **Azure Account:** Sign up for an Azure account if you don't have one.
- **GitHub Account:** Create a GitHub account to host your code repositories.
- **Basic Knowledge of Command Line:** Familiarity with using the terminal or command prompt.
- **SSH Key Pair:** Generate an SSH key pair for secure access to your VMs. [How to Generate SSH Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## Understanding Key Concepts

### Azure Virtual Machines

**Azure Virtual Machines (VMs)** are scalable computing resources provided by Microsoft Azure. They allow you to run applications and services in the cloud with customizable configurations, including operating systems, storage, and networking.

- **Benefits:**
    - **Scalability:** Easily scale resources based on demand.
    - **Flexibility:** Choose from various operating systems and configurations.
    - **Cost-Effective:** Pay only for the resources you use.

### Git and GitHub

**Git** is a version control system that tracks changes in your codebase, allowing multiple developers to collaborate efficiently. **GitHub** is a cloud-based hosting service for Git repositories, enabling easy collaboration and code sharing.

- **Key Commands:**
    - `git init`: Initialize a new Git repository.
    - `git add`: Add files to the staging area.
    - `git commit`: Commit changes with a descriptive message.
    - `git push`: Push commits to a remote repository.

### NGINX

**NGINX** is a high-performance web server that can also function as a reverse proxy, load balancer, and HTTP cache. It's commonly used to serve static content, manage traffic, and enhance application performance.

### MongoDB

**MongoDB** is a NoSQL, open-source database that stores data in flexible, JSON-like documents. It's designed for scalability and performance, making it ideal for modern applications.

### PM2

**PM2** is a production-grade process manager for Node.js applications. It ensures your app runs continuously, handles restarts, and manages logs, providing a reliable environment for your applications.

---

## Initial Setup

### Creating and Syncing a Git Repository

Managing your application's code using Git and GitHub ensures version control and collaboration efficiency.

1. **Create a Local Repository Folder:**
    
    - Open your terminal or command prompt.
    - Create a new directory for your project:
        
        
        `mkdir tech501-sparta-app cd tech501-sparta-app`
        `cd tech501-sparta-app`
        
    - **Explanation:**
        - `mkdir tech501-sparta-app`: Creates a new folder named `tech501-sparta-app`.
        - `cd tech501-sparta-app`: Navigates into the newly created directory.
2. **Initialize Git and Commit:**
    
    - Initialize a new Git repository:
        
        
        `git init`
        
        - **Explanation:** `git init` sets up a new Git repository in the current directory.
    - Rename the default branch from `master` to `main`:
        
        
        `git branch -m master main`
        
        - **Explanation:** Modern Git practices use `main` as the default branch name.
    - Add all files to the staging area:
        
        
        `git add .`
        
        - **Explanation:** `git add .` stages all files in the current directory for the next commit.
    - Commit the changes with a descriptive message:
        
        
        `git commit -m "Initial commit"`
        
        - **Explanation:** `git commit` records the staged changes with the message "Initial commit".
3. **Create a GitHub Repository:**
    
    - Navigate to [GitHub](https://github.com/) and create a new repository named `tech501-sparta-app`.
    - Ensure the repository name matches your local folder for consistency.
4. **Push Local Repository to GitHub:**
    
    - Add the remote repository:
        
        
        `git remote add origin https://github.com/Haashimc123/tech501-sparta-app.git`
        
        - **Explanation:** Links your local repository to the GitHub repository.
    - Push the commits to GitHub:
        
        
        `git push -u origin main`
        
        - **Explanation:** `git push` uploads your local commits to GitHub. The `-u` flag sets `origin main` as the default upstream branch.

---

## Deploying the Application

### Creating the First VM for the Application

This VM will host your application. We'll set it up with Ubuntu Server and necessary configurations. We will then create an image of this VM and recreate it as second deployment vm

1. **Log in to Azure Portal:**
    
    - Navigate to [Azure Portal](https://portal.azure.com/) and sign in with your credentials.
2. **Create a New Virtual Machine:**
    
    - **Steps:**
        - Click on **"Create a resource"** in the upper left corner.
        - Select **"Virtual Machine"**.
    - **Configuration Details:**
        - **Basics Tab:**
            - **Resource Group:** Create a new resource group or use an existing one. A resource group is a container that holds related resources for an Azure solution.
            - **Virtual Machine Name:** `tech501-haashim-first-deploy-app-vm`
            - **Region:** Select a region closest to your users for better performance.
            - **Image:** Choose **Ubuntu Server 22.04 LTS (x64, Gen2)**. Ubuntu is a popular Linux distribution known for its stability and security.
            - **Size:** Select **Standard B1s** for cost-effectiveness, suitable for small applications.
            - **Authentication Type:** Select **SSH public key** for secure access.
            - **Username:** `adminuser`
            - **SSH Public Key:** Paste your generated SSH public key.
        - **Disks Tab:**
            - **OS Disk Type:** **Standard SSD** offers a balance between performance and cost.
        - **Networking Tab:**
            - **Virtual Network:** Use an existing virtual network or create a new one.
            - **Subnet:** Select your public subnet to allow internet access.
            - **Public IP:** Ensure a public IP is assigned for external access.
            - **NIC Network Security Group:** Create a new NSG or use an existing one.
                - **Inbound Port Rules:** Allow SSH (port 22) and HTTP (port 80).
        - **Management, Advanced, and Tags Tabs:**
            - Leave default settings unless specific configurations are required.
    - **Review and Create:**
        - Review your configurations.
        - Click **"Create"** to deploy the VM.
3. **Understanding the Configuration:**
    
    - **Ubuntu Server 22.04 LTS:** A long-term support version ensuring stability and security updates.
    - **Standard B1s:** A cost-effective VM size suitable for small workloads.
    - **SSH Authentication:** Securely access your VM without passwords.
    - **NSG Rules:** Define which traffic is allowed to reach your VM.

### Installing Necessary Software on the VM

After creating the VM, you'll need to install essential software like NGINX, Node.js, and Git.

1. **Access the VM via SSH:**
    
    - Open your terminal or command prompt.
    - Connect to your VM using SSH:
        
        
        `ssh adminuser@<VM_Public_IP>`
        
        - **Explanation:** Replace `<VM_Public_IP>` with your VM's public IP address. This command initiates a secure connection to your VM.
2. **Update and Upgrade System Packages:**
    
    - Run the following commands to ensure your system is up-to-date:
        
        
        `sudo apt-get update -y` 
        `sudo apt-get upgrade -y`
        
        - **Explanation:**
            - `sudo`: Executes the command with superuser privileges.
            - `apt-get update`: Fetches the latest package lists from repositories.
            - `apt-get upgrade`: Installs the newest versions of all packages.
            - `-y`: Automatically answers "yes" to prompts.
3. **Install NGINX:**
    
    - NGINX will serve as a web server and reverse proxy.
        
        
        `sudo apt-get install nginx -y` 
        `sudo systemctl status nginx`
        
        - **Explanation:**
            - `apt-get install nginx`: Installs the NGINX web server.
            - `systemctl status nginx`: Checks the status of the NGINX service to ensure it's running.
4. **Install Node.js and NPM:**
    
    - Node.js is a JavaScript runtime, and NPM is its package manager.
        
        
        `sudo apt-get install nodejs npm -y node -v npm -v`
        
        - **Explanation:**
            - `apt-get install nodejs npm`: Installs Node.js and NPM.
            - `node -v`: Displays the installed Node.js version.
            - `npm -v`: Displays the installed NPM version.

---

## Configuring the Second VM

The second VM will serve as an additional instance for your application, enhancing scalability and reliability.

### Creating the Second VM

1. **Create a New Virtual Machine:**
    - Follow the same steps as creating the first VM with slight modifications.
        
    - **Configuration Details:**
        
        - **Virtual Machine Name:** `tech501-haashim-second-deploy-app-vm`
        - **Networking:**
            - **Subnet:** Ensure it’s in the same virtual network as the first VM.
            - **Public IP:** Assign a new public IP address.
            - **NSG Rules:** Allow SSH (port 22), HTTP (port 80), and custom port **3000** for application traffic.
    - **Review and Create:**
        
        - After configuring, click **"Create"** to deploy the second VM.

### Setting Up Network Security Groups (NSGs)

NSGs control inbound and outbound traffic to your VMs. Proper configuration ensures security and accessibility.

1. **Create a New NSG:**
    
    - Name: `tech501-haashim-sparta-app-allow-HTTP-SSH-3000`
2. **Add Inbound Security Rules:**
    
    - **Allow SSH:**
        - **Priority:** 1000
        - **Source:** Any
        - **Source Port Range:** *
        - **Destination:** Any
        - **Destination Port Range:** 22
        - **Protocol:** TCP
        - **Action:** Allow
        - **Description:** Allows SSH access.
    - **Allow HTTP:**
        - **Priority:** 1100
        - **Source:** Any
        - **Source Port Range:** *
        - **Destination:** Any
        - **Destination Port Range:** 80
        - **Protocol:** TCP
        - **Action:** Allow
        - **Description:** Allows HTTP traffic.
    - **Allow Custom Port 3000:**
        - **Priority:** 1200
        - **Source:** Any
        - **Source Port Range:** *
        - **Destination:** Any
        - **Destination Port Range:** 3000
        - **Protocol:** TCP
        - **Action:** Allow
        - **Description:** Allows application traffic on port 3000.
3. **Associate NSG with VM Network Interface:**
    
    - Navigate to the **Network Interface** of your second VM.
    - Associate the newly created NSG `tech501-haashim-sparta-app-allow-HTTP-SSH-3000` with the NIC.

---

## Deploying the App Using SCP or Git Clone

Deploying your application code to the VM can be done using either **SCP** (Secure Copy Protocol) or **Git Clone**. We'll focus on the Git Clone method for its efficiency and version control benefits.

### Git Clone Method

1. **Upload Code to GitHub:**
    
    - Ensure your application code is committed and pushed to your GitHub repository `tech501-sparta-app`.
2. **Clone Repository on VM:**
    
    - SSH into your second VM:
        
        
        `ssh adminuser@<Second_VM_Public_IP>`
        
    - Navigate to the home directory or your desired project directory:
        
        
        `cd ~`
        
    - Clone the GitHub repository:
        
        
        `git clone https://github.com/Haashimc123/tech501-sparta-app.git`
        
        - **Explanation:** Downloads the repository from GitHub to your VM.
    - Navigate into the cloned repository:
        
        
        `cd tech501-sparta-app`
        
3. **Install NPM Dependencies and Start the App:**
    
    - Install the required Node.js packages:
        
        
        `npm install`
        
        - **Explanation:** Reads the `package.json` file and installs all listed dependencies.
    - Start the application:
        
        
        `npm start`
        
        - **Explanation:** Runs the application, typically starting a server that listens on a specified port (e.g., port 3000).
4. **Verify App Deployment:**
    
    - Obtain the VM's public IP from the Azure Portal.
    - Open a web browser and navigate to `http://<Second_VM_Public_IP>:3000`.
    - You should see your application running.

---

## Setting Up the Database VM

A dedicated Database VM ensures that your application has a reliable and scalable data storage solution.

### Creating the Database VM

1. **Create a New Virtual Machine:**
    - Follow the steps similar to creating the first and second VMs.
        
    - **Configuration Details:**
        
        - **Virtual Machine Name:** `tech501-haashim-sparta-app-db-vm`
        - **OS:** Ubuntu Server 22.04 LTS (x64, Gen2)
        - **Size:** Standard B1s
        - **Authentication Type:** SSH public key
        - **SSH Key:** Use the existing SSH key.
    - **Networking:**
        
        - **Virtual Network:** Use the same virtual network as the app VMs.
        - **Subnet:** Select `private-subnet` to restrict direct internet access.
        - **Public IP:** **Do not** assign a public IP for enhanced security.
        - **NSG Rules:** Allow only SSH (port 22) and MongoDB port (default 27017).
    - **Review and Create:**
        
        - After configuring, click **"Create"** to deploy the Database VM.

### Installing and Configuring MongoDB

1. **Access the Database VM via SSH:**
    
    - Open your terminal and connect:
        
        
        `ssh adminuser@<DB_VM_Public_IP>`
        
        - **Note:** If you didn't assign a public IP, access the VM through a jump host or Azure Bastion.
2. **Update and Upgrade System Packages:**
    
    
    `sudo apt-get update -y` 
    `sudo apt-get upgrade -y`
    
3. **Install MongoDB:**
    
    
    `sudo apt-get install -y mongodb`
    
    - **Explanation:** Installs the MongoDB database server.
4. **Configure MongoDB to Accept Remote Connections:**
    
    - **Edit MongoDB Configuration File:**
        
        
        `sudo nano /etc/mongodb.conf`
        
    - **Modify Bind IP:**
        - Locate the line that starts with `bind_ip` and change it from `127.0.0.1` to `0.0.0.0`:
            
            
            `bind_ip = 0.0.0.0`
            
        - **Explanation:** Allows MongoDB to accept connections from any IP address. **Security Note:** This configuration is suitable for testing but should be secured for production environments.
    - **Save and Exit:**
        - Press `CTRL + X`, then `Y`, and `Enter` to save changes.
5. **Enable and Restart MongoDB:**
    
    
    `sudo systemctl enable mongod` 
    `sudo systemctl restart mongod` 
    `sudo systemctl status mongod`
    
    - **Explanation:**
        - `enable mongod`: Ensures MongoDB starts on system boot.
        - `restart mongod`: Restarts the MongoDB service to apply configuration changes.
        - `status mongod`: Checks if MongoDB is running correctly.
6. **Freeze MongoDB Version (Optional):**
    
    - Prevents MongoDB from being updated automatically:
        
        
        `echo "mongodb-org hold" | sudo dpkg --set-selections echo "mongodb-org-database hold" | sudo dpkg --set-selections echo "mongodb-org-server hold" | sudo dpkg --set-selections echo "mongodb-mongosh hold" | sudo dpkg --set-selections echo "mongodb-org-mongos hold" | sudo dpkg --set-selections echo "mongodb-org-tools hold" | sudo dpkg --set-selections`
        
        - **Explanation:** Locks the MongoDB packages to prevent unintended upgrades.

---

## Connecting the Application VM to the Database VM

Establishing a secure and reliable connection between your application and database ensures data integrity and performance.

1. **Obtain the Private IP of the Database VM:**
    
    - In the Azure Portal, navigate to the **Database VM**.
    - Locate the **Private IP address** under the **Networking** section.
2. **Set Connection String as Environment Variable on App VM:**
    
    - SSH into your **second app VM**:
        
        
        `ssh adminuser@<Second_VM_Public_IP>`
        
    - Navigate to your application directory:
        
        
        `cd tech501-sparta-app`
        
    - Export the database host environment variable:
        
        
        `export DB_HOST="mongodb://<DB_VM_Private_IP>:27017/yourdatabase"`
        
        - **Explanation:** Sets the `DB_HOST` environment variable to the MongoDB connection string, pointing to the Database VM's private IP.
3. **Persist the Environment Variable:**
    
    - To ensure the variable persists across sessions, add it to the `.bashrc` or `.profile` file:
        
        
        `echo 'export DB_HOST="mongodb://<DB_VM_Private_IP>:27017/yourdatabase"' >> ~/.bashrc source ~/.bashrc`
        
4. **Install Dependencies and Start the Application:**
    
    - Ensure all dependencies are installed:
        
        
        `npm install`
        
    - Start the application:
        
        
        `npm start`
        
5. **Seed the Database (If Necessary):**
    
    - If the database is empty, seed it with initial data:
        
        
        `node seeds/seed.js`
        
        - **Explanation:** Runs a script to populate the database with dummy records.
6. **Verify Connection:**
    
    - Open a web browser and navigate to `http://<Second_VM_Public_IP>:3000/posts`.
    - You should see a message indicating that the database is seeded and connected.

---

## Setting Up a Reverse Proxy with NGINX

A reverse proxy like NGINX can manage incoming traffic, improve security, and enhance performance by directing requests to the appropriate backend services.

1. **Backup the Existing NGINX Configuration:**
    
    
    `sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup`
    
    - **Explanation:** Creates a backup of the default NGINX configuration file.
2. **Edit the NGINX Configuration File:**
    
    
    `sudo nano /etc/nginx/sites-available/default`
    
    - **Explanation:** Opens the NGINX configuration file for editing.
3. **Modify the `location` Block:**
    
    - **Original Configuration:**
        
        
        `location / {     try_files $uri $uri/ =404; }`
        
    - **Updated Configuration:**
        
        
        `location / {     proxy_pass http://127.0.0.1:3000;     proxy_http_version 1.1;     proxy_set_header Upgrade $http_upgrade;     proxy_set_header Connection 'upgrade';     proxy_set_header Host $host;     proxy_cache_bypass $http_upgrade; }`
        
        - **Explanation:**
            - `proxy_pass`: Forwards incoming requests to the application running on port 3000.
            - `proxy_set_header`: Sets necessary headers for proper communication between NGINX and the application.
            - `proxy_http_version`: Specifies the HTTP version to use.
4. **Test the NGINX Configuration:**
    
    
    `sudo nginx -t`
    
    - **Explanation:** Checks the syntax of the NGINX configuration file to ensure there are no errors.
5. **Reload NGINX to Apply Changes:**
    
    
    `sudo systemctl reload nginx`
    
    - **Explanation:** Reloads the NGINX service, applying the new configuration without downtime.
6. **Verify Reverse Proxy Setup:**
    
    - Open a web browser and navigate to `http://<App_VM_Public_IP>/`.
    - The application should load without needing to specify port `3000`.

---

## Managing the Application with PM2

Running your application with PM2 ensures it remains active, even after system reboots or crashes, and provides easy management of multiple instances.

1. **Install PM2 Globally:**
    
    
    `sudo npm install -g pm2 pm2 --version`
    
    - **Explanation:**
        - `npm install -g pm2`: Installs PM2 globally, making it accessible from any directory.
        - `pm2 --version`: Checks the installed PM2 version to verify successful installation.
2. **Start the Application with PM2:**
    
    
    `cd tech501-sparta-app pm2 start app.js`
    
    - **Explanation:**
        - `pm2 start app.js`: Launches the application using PM2, managing it as a background process.
3. **Manage the Application:**
    
    - **Check Status:**
        
        
        `pm2 status`
        
        - **Explanation:** Displays the status of all applications managed by PM2.
    - **Stop the Application:**
        
        
        `pm2 stop app.js`
        
        - **Explanation:** Stops the specified application.
    - **Restart the Application:**
        
        
        `pm2 restart app.js`
        
        - **Explanation:** Restarts the specified application.
    - **View Logs:**
        
        
        `pm2 logs app.js`
        
        - **Explanation:** Displays real-time logs for the specified application.
4. **Ensure PM2 Restarts on System Reboot:**
    
    
    `pm2 startup systemd pm2 save`
    
    - **Explanation:**
        - `pm2 startup systemd`: Generates and configures a startup script to launch PM2 and managed applications on boot.
        - `pm2 save`: Saves the current process list, ensuring PM2 restores them after a reboot.

---

## Creating and Using VM Images

Creating VM images allows you to replicate your configured VMs quickly, ensuring consistency across deployments.

1. **Capture VM Image:**
    
    - **Steps:**
        - Navigate to the **first app VM** in the Azure Portal.
        - Click on **"Capture"** from the top menu.
        - **Options:**
            - **Image Name:** `tech501-haashim-app-image`
            - **Resource Group:** Choose an existing group or create a new one.
            - **Select:** "No, capture only a managed image" (uncheck the gallery option).
            - **Generalize:** Ensure the VM is generalized (deprovisioned) by running `sudo waagent -deprovision+user` before capturing.
    - **Explanation:** Capturing an image creates a template of the VM's OS and installed software, which can be used to deploy new VMs with the same configuration.
2. **Create New VM from Image:**
    
    - **Steps:**
        - Go to the **Images** section in the Azure Portal.
        - Select the **captured image** `tech501-haashim-app-image`.
        - Click **"Create VM"**.
    - **Configuration Details:**
        - **Virtual Machine Name:** `tech501-haashim-new-app-vm`
        - **Region:** Same as the image.
        - **Size:** Standard B1s
        - **Authentication Type:** SSH public key
        - **SSH Key:** Use existing SSH key.
        - **Networking:** Assign to the appropriate subnet and NSG.
    - **Explanation:** Deploying from an image ensures that the new VM has the same setup as the original, including installed software and configurations.
3. **Benefits of Using VM Images:**
    
    - **Consistency:** Ensures all VMs have identical configurations.
    - **Speed:** Rapid deployment without manual setup.
    - **Scalability:** Easily scale out by deploying multiple VMs from the same image.

---
## Creating a Virtual Machine Scale Set

**Virtual Machine Scale Sets (VMSS)** allow you to deploy and manage a set of identical VMs, ensuring high availability and scalability for your applications. VMSS automatically increases or decreases the number of VM instances based on demand or predefined schedules.

### Why Use a Virtual Machine Scale Set?

- **Scalability:** Automatically scale the number of VMs based on application load.
- **High Availability:** Distribute VMs across multiple availability zones to ensure reliability.
- **Cost-Efficiency:** Pay only for the resources you use by scaling in and out as needed.
- **Simplified Management:** Manage a group of VMs as a single entity.

### Parameters File Overview

The parameters file provides specific values for the template's configurable inputs, ensuring the deployment aligns with the desired environment and requirements:

- **Location:** Deploys resources to the `uksouth` Azure region.
- **OS Disk Type:** Uses `StandardSSD_LRS` for OS disks, balancing performance and cost.
- **Networking:**
    - **Virtual Network ID and Name:** References an existing VNet named `tech501-haashim-2-subnet-vnet`.
    - **Subnet:** Utilizes the `public-subnet` within the specified VNet.
    - **Network Security Group (NSG):** Applies security rules from `tech501-haashim-sparta-app-allow-http-ssh-3000` to control inbound traffic (e.g., HTTP and SSH).
- **Load Balancer:**
    - **Name:** `tech501-haashim-sparta-app-lb`
    - **Backend Pool Name:** `bepool`
    - **Ports:** Frontend and backend ports set to `80` for HTTP traffic.
    - **Protocol:** Uses `Tcp` for load balancing rules.
    - **NAT Rule Ports:** Starts at `50000` to facilitate SSH access to VMs.
- **VM Scale Set:**
    - **Name:** `tech501-haashim-sparta-app-vmss`
    - **Instance Count:** Starts with `2` instances.
    - **Instance Size:** Utilizes `Standard_B1s` VMs for cost-effective performance.
    - **Zones:** Distributes VMs across zones `1`, `2`, and `3`.
    - **Scaling Policies:** Sets up rules to scale based on CPU usage, with a minimum of `2` and a maximum of `3`instances.
    - **Upgrade Policy:** Set to `Manual` for controlled updates.
- **Admin Credentials:**
    - **Username:** `adminuser`
    - **SSH Key:** Select **`tech-501-haashim-az-key`** from the Azure store.
- **Health Extension:**
    - **Protocol:** `http`
    - **Port:** `80`
    - **Request Path:** `/` for health checks.
- **Auto Repairs Policy:**
    - **Enabled:** `true`
    - **Grace Period:** `PT10M` (10 minutes) before initiating repairs.
    - **Action:** Replace faulty instances.
- **User Data:**
    - **Value:** Encoded script (`IyEvYmluL2Jhc2gKCmNkIC9yZXBvL2FwcAoKcG0yIHN0YXJ0IGFwcC5qcw==`) which decodes to:
        
        
        `#!/bin/bash  cd /repo/app  pm2 start app.js`
        
    - **Purpose:** Navigates to the application directory and starts the application using PM2, a Node.js process manager.

### Step-by-Step Guide to Creating the VM Scale Set

#### Prerequisites

- **Existing Virtual Network (VNet):** Ensure you have a VNet named `tech501-haashim-2-subnet-vnet` with a subnet named `public-subnet`.
- **Network Security Group (NSG):** Ensure the NSG `tech501-haashim-sparta-app-allow-http-ssh-3000` exists with appropriate inbound rules.
- **Load Balancer:** A new load balancer will be created as part of this setup.
- **User Data Script:** Ensure the `sparta-app-first-deploy.sh` script is prepared and encoded if necessary.

#### 1. Orchestration

A scale set has a **"scale set model"** that defines the attributes of virtual machine instances, such as size, number of data disks, and more. As the number of instances in the scale set changes, new instances are added or removed based on this model.

**Recommendation:** Choose **Uniform** orchestration mode for most applications to take advantage of simplified scaling and management.

#### 2. Create a New Load Balancer

Instead of selecting an existing load balancer, we'll create a new one specifically for the VM Scale Set.

1. **Navigate to Azure Portal:**
    
    - Open [Azure Portal](https://portal.azure.com/) and sign in.
2. **Create a New Load Balancer:**
    
    - Click on **"Create a resource"** in the upper left corner.
    - Search for **"Load Balancer"** and select it.
    - Click **"Create"**.
3. **Load Balancer Configuration:**
    
    - **Name:** `tech501-haashim-sparta-app-lb`
    - **SKU:** Standard
    - **Type:** Public
    - **Frontend IP Configuration:**
        - **Name:** `PublicIPAddress`
        - **IP Version:** IPv4
        - **Public IP Address:** Create a new public IP or select an existing one.
4. **Backend Pool Configuration:**
    
    - **Name:** `bepool`
    - **Add VMs:** Leave empty for now; it will be associated with the VM Scale Set later.
5. **Configure Health Probes:**
    
    - **Name:** `healthprobe`
    - **Protocol:** HTTP
    - **Port:** `80`
    - **Path:** `/`
    - **Interval:** 15 seconds
    - **Unhealthy Threshold:** 2
6. **Configure Load Balancing Rules:**
    
    - **Name:** `httpRule`
    - **Frontend IP Address:** Select `PublicIPAddress`.
    - **Backend Pool:** Select `bepool`.
    - **Protocol:** TCP
    - **Frontend Port:** `80`
    - **Backend Port:** `80`
    - **Health Probe:** Select `healthprobe`.
    - **Idle Timeout (minutes):** 5
    - **Enable Floating IP:** Disabled
7. **Configure NAT Rules for SSH Access:**
    
    - **Name:** `SSH_NAT`
    - **Frontend IP Address:** Select `PublicIPAddress`.
    - **Protocol:** TCP
    - **Frontend Port Range:** `50000-50099`
    - **Backend Port:** `22`
    - **Enable TCP Reset:** Enabled
8. **Review and Create:**
    
    - Review all settings.
    - Click **"Create"** to deploy the load balancer.

**Explanation:**

- **Load Balancer:** Distributes incoming HTTP traffic across VM instances.
- **Health Probes:** Monitor the health of VMs to ensure traffic is only sent to healthy instances.
- **NAT Rules:** Facilitate SSH access to individual VMs within the scale set without exposing them directly to the internet.

#### 3. Configure Network Interface Settings for the NIC

1. **Edit Network Interface (NIC) Settings:**
    
    - Navigate to the **Network Interfaces** section in the Azure Portal.
    - Select the NIC associated with the VM Scale Set or proceed to configure it during the VM Scale Set creation.
2. **Subnet Configuration:**
    
    - **Subnet:** Change to `public-subnet` with the address range `10.0.2.0/24`.
    - **Explanation:** Ensures that the VM instances are placed within the correct subnet, allowing them to communicate with each other and access necessary resources.
3. **Associate Network Security Group (NSG):**
    
    - **Name:** `tech501-haashim-sparta-app-allow-http-ssh-3000`
        
    - **Steps:**
        
        - In the NIC settings, go to **"Network security group"**.
        - Select **"Advanced"**.
        - Choose the existing NSG `tech501-haashim-sparta-app-allow-http-ssh-3000` from the dropdown.
    - **Explanation:** Applies security rules to control inbound traffic, ensuring only HTTP and SSH traffic is allowed.
        

#### 4. Instance Details

1. **License Type:**
    - **Selection:** Choose **"Other"**.
    - **Explanation:** Selecting the appropriate license type ensures compliance and correct billing. "Other" is used when the VM does not require a specific license or when using custom licensing.

#### 5. Scaling Policy

1. **Choose Scaling Policy:**
    
    - **Option:** **Auto**
    - **Explanation:** Allows Azure to automatically adjust the number of VM instances based on predefined rules and metrics, ensuring optimal performance and cost-efficiency.
2. **Configure Scaling Rules:**
    
    - **Minimum Instances:** `2`
        
    - **Maximum Instances:** `3`
        
    - **Scale-Out Rule:**
        
        - **Condition:** CPU usage exceeds `75%`
        - **Action:** Scale out to `3` instances.
    - **Scale-In Rule:**
        
        - **Condition:** CPU usage drops below `20%`
        - **Action:** Scale in to `2` instances.
    - **Example:**
        
        
        `scalingRules:   scaleOut:     threshold: 75     direction: increase     adjustment: +1     cooldown: 300   scaleIn:     threshold: 20     direction: decrease     adjustment: -1     cooldown: 300`
        
    - **Explanation:** These rules ensure that your application can handle increased load by adding more instances when CPU usage is high and reducing instances when the load decreases, optimizing both performance and costs.
        

#### 6. Health

1. **Enable Application Health Monitoring:**
    
    - **Setting:** Selected
    - **Explanation:** Monitors the health of your application to ensure it is running smoothly. If the application becomes unhealthy, Azure can take corrective actions automatically.
2. **Configure Recovery Settings:**
    
    - **Enable Automatic Repairs:** `true`
        
    - **Grace Period:** `PT10M` (10 minutes)
        
    - **Action:** Replace faulty instances.
        
    - **Explanation:** If a VM instance becomes unhealthy, Azure waits for 10 minutes before attempting to repair or replace it, ensuring minimal disruption to your application.
        

#### 7. Reimaging VM Scale Set Instances

1. **Reimaging the Instances:**
    - **Instances to Reimage:**
        
        - `tech501-haashim-sparta-app-vmss2_0`
        - `tech501-haashim-sparta-app-vmss2_1`
    - **Reason for Reimaging:**
        
        - The user script `pm2 start app.js` only runs once when instances are first created. If instances are stopped and started again, the script does not execute automatically because `npm run` isn't being run in the correct directory. Reimaging ensures that the instances are in a healthy state with the necessary startup scripts executed properly.
        - **Alternative Fix:** Enable the **Autohealing** option to automatically detect and remediate unhealthy instances without manual intervention.
    - **Steps to Reimage:**
        
        1. Navigate to the **VM Scale Set** `tech501-haashim-sparta-app-vmss2` in the Azure Portal.
        2. Select **Instances**.
        3. Choose the instance `tech501-haashim-sparta-app-vmss2_0` and click **Reimage**.
        4. Repeat the process for the instance `tech501-haashim-sparta-app-vmss2_1`.
        5. Confirm the reimaging process when prompted.
    - **Explanation:** Reimaging refreshes the VM instances, ensuring that the startup scripts are executed correctly, and the instances return to a healthy state.
        

#### 8. SSHing into the Load Balancer

1. **SSH Access via Load Balancer:**
    - **Why SSH Through Load Balancer:**
        - Direct SSH access to individual VM instances in a scale set is not recommended due to security concerns and the dynamic nature of scale sets. Instead, SSHing through the load balancer using NAT rules ensures secure and managed access.
    - **Steps to SSH into VM Instances via Load Balancer:**
        1. Obtain the **Public IP Address** of the load balancer `tech501-haashim-sparta-app-lb` from the Azure Portal.
        2. Determine the **NAT Port** assigned to the specific VM instance. For example, instance `tech501-haashim-sparta-app-vmss2_0` might use port `50000`, and `tech501-haashim-sparta-app-vmss2_1`might use port `50001`.
        3. Use the following SSH command, replacing `<Load_Balancer_Public_IP>`, `<NAT_Port>`, and `<Username>` accordingly:
            
            
            `ssh adminuser@<Load_Balancer_Public_IP> -p <NAT_Port>`
            
            - **Example:**
                
                
                `ssh adminuser@52.174.34.12 -p 50000`
                
    - **Explanation:** SSHing through the load balancer using NAT ports provides controlled and secure access to individual VM instances without exposing them directly to the internet.

#### 9. Deallocating and Reimaging Unhealthy Instances

1. **Identify Unhealthy Instances:**
    
    - Navigate to the **VM Scale Set** `tech501-haashim-sparta-app-vmss2` in the Azure Portal.
    - Check the **Instance Health** status to identify any unhealthy VMs.
2. **Deallocate and Reimage Unhealthy Instances:**
    
    - **Steps:**
        1. Select the unhealthy instance (e.g., `tech501-haashim-sparta-app-vmss2_0`).
        2. Click on **"Stop"** to deallocate the VM.
        3. Once deallocated, click on **"Reimage"** to refresh the VM instance.
        4. Confirm the reimaging process when prompted.
    - **Explanation:** Deallocating and reimaging resets the VM instance, ensuring that it returns to a healthy state with all startup scripts executed correctly.

#### 10. How to Delete the VM Scale Set

1. **Navigate to the VM Scale Set:**
    
    - Open the Azure Portal and go to the **Resource Group** containing the VM Scale Set.
    - Select the **Virtual Machine Scale Set** `tech501-haashim-sparta-app-vmss`.
2. **Delete the VM Scale Set:**
    
    - Click on **"Delete"** at the top of the VM Scale Set overview page.
        
    - Confirm the deletion by typing the VM Scale Set name when prompted.
        
    - **Explanation:** Deleting the VM Scale Set removes all associated VM instances and resources, ensuring that no unnecessary resources continue to incur costs.
        

#### 11. How to Delete the Load Balancer

1. **Navigate to the Load Balancer:**
    
    - Open the Azure Portal and go to the **Resource Group** containing the load balancer.
    - Select the **Load Balancer** `tech501-haashim-sparta-app-lb`.
2. **Delete the Load Balancer:**
    
    - Click on **"Delete"** at the top of the Load Balancer overview page.
        
    - Confirm the deletion by typing the Load Balancer name when prompted.
        
    - **Explanation:** Deleting the load balancer ensures that all associated frontend IP configurations, backend pools, health probes, load balancing rules, and NAT rules are removed, preventing any unintended traffic routing or costs.
        

### Verifying the VM Scale Set Deployment

1. **Monitor Deployment:**
    
    - Navigate to the **Resource Group** in the Azure Portal.
    - Locate the **VM Scale Set** `tech501-haashim-sparta-app-vmss`.
    - Check the **Instances** to ensure that two VM instances are running.
2. **Test Load Balancer:**
    
    - Obtain the **Public IP Address** of the load balancer `tech501-haashim-sparta-app-lb`.
    - Open a web browser and navigate to `http://<Load_Balancer_Public_IP>/`.
    - The application should load, and traffic should be distributed across the VM instances in the scale set.
3. **Verify Scaling Policies:**
    
    - **Simulate Load:**
        - Use tools like Apache Bench to generate CPU load on the VMs.
    - **Monitor Scaling:**
        - Observe the **Instance Count** in the VM Scale Set to ensure it scales out to three instances when CPU usage exceeds `75%`.
        - Reduce the load and verify that it scales back in to two instances when CPU usage drops below `20%`.
4. **Health Checks:**
    
    - Ensure that the health extension is correctly monitoring the application.
    - Verify that any unhealthy VM instances are automatically repaired or replaced according to the auto repairs policy.

### Summary of Key Configurations

- **Orchestration Mode:** Uniform for simplified management and scaling.
- **Scaling Policy:** Auto with rules to scale out to `3` instances at `75%` CPU and scale in to `2` instances at `20%` CPU.
- **Load Balancer:** Newly created `tech501-haashim-sparta-app-lb` with backend pool `bepool` and NAT rules for SSH access.
- **Networking:** VMs placed in `public-subnet` with NSG `tech501-haashim-sparta-app-allow-http-ssh-3000`.
- **Health Monitoring:** Enabled application health checks and automatic repairs to maintain VM integrity.
- **User Data Script:** Automates application startup using PM2 upon VM provisioning.
- **SSH Key:** Selected **`tech-501-haashim-az-key`** from the Azure store for secure access.

---

## Automating Deployment with User Data Scripts

Automation scripts streamline the deployment process, reducing manual intervention and potential errors.

### Purpose

User Data scripts execute commands automatically during the VM provisioning process. They can set environment variables, start services, and perform other setup tasks without manual SSH access.

### Creating the `sparta-app-first-deploy.sh` Script

1. **Script Content:**
    
    
    `#!/bin/bash # Navigate to the app directory cd /home/adminuser/tech501-sparta-app  # Export environment variable with the DB VM's private IP export DB_HOST="mongodb://10.x.x.x:27017/yourdatabase"  # Start the app using PM2 pm2 start app.js`
    
    - **Explanation:**
        - `#!/bin/bash`: Specifies the script should run in the Bash shell.
        - `cd /home/adminuser/tech501-sparta-app`: Navigates to the application directory.
        - `export DB_HOST=...`: Sets the `DB_HOST` environment variable to the MongoDB connection string.
        - `pm2 start app.js`: Launches the application using PM2.
2. **Implementing the Script During VM Creation:**
    
    - **Steps:**
        - When creating a new VM from an image, navigate to the **Advanced** tab.
        - Enable the **User Data** option.
        - Paste the contents of `sparta-app-first-deploy.sh` into the **User Data** field.
    - **Explanation:** The script runs automatically when the VM is provisioned, setting up the necessary environment and starting the application without manual intervention.

### Benefits of Automation Scripts

- **Efficiency:** Reduces the need for manual setup steps.
- **Consistency:** Ensures all deployments follow the same configuration.
- **Scalability:** Easily deploy multiple instances with identical setups.

---

## Best Practices for Deleting VMs

Properly deleting VMs ensures that no unnecessary resources are left running, which can incur unwanted costs and security risks.

### Deletion Steps

1. **Identify Associated Resources:**
    
    - Determine all resources linked to the VM, including:
        - **Virtual Machine**
        - **Public and Private IP Addresses**
        - **Network Security Groups (NSGs)**
        - **Network Interfaces**
        - **Disks (OS and Data)**
    - **Tip:** Use consistent naming conventions (e.g., `week1-vm`) to easily identify related resources.
2. **Do Not Delete Resource Groups:**
    
    - **Explanation:** Resource groups may contain other critical resources. Only delete the specific resources associated with the VM to avoid unintended disruptions.
3. **Force Delete the VM:**
    
    - **Steps:**
        - Navigate to the **Virtual Machine** in the Azure Portal.
        - Click on the **three-dot menu** (ellipsis) next to the VM name.
        - Select **"Delete"**.
        - Choose **"Force Delete"** to remove all associated resources.
        - Confirm the deletion by typing the VM name when prompted.
    - **Explanation:** Force deleting ensures that all linked resources (IP, NSG, NIC, disks) are removed alongside the VM.
4. **Verify Deletion:**
    
    - Check the **Resource Groups** and **All Resources** sections to ensure that no remnants of the VM remain.

### Additional Tips

- **Monitor Resource Usage:** Regularly review your Azure resources to identify and remove unused or unnecessary assets.
- **Security:** Ensure that deleting VMs does not leave sensitive data exposed. Always backup important data before deletion.

---

## Conclusion

Deploying applications and databases on Azure Virtual Machines involves several steps, from setting up your development environment to configuring network security and automating deployments. This guide has walked you through each stage, providing detailed explanations and best practices to ensure a successful and secure deployment.

