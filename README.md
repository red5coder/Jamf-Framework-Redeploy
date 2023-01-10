# Jamf-Framework-Redeploy
With the release of Jamf Pro 10.36, a new API endpoint was added, which allows you to distribute a QuickAdd.pkg to the macOS client to re-deploy the Jamf Framework. Under the hood, its using the InstallEnterpriseApplication MDM command.

The Jamf Framework Redeploy utility will allow you to easily call this API, and re-deploy the Jamf Framework for a selected computer.
<img width="612" alt="app" src="https://user-images.githubusercontent.com/29920386/211601229-bd8e5258-ddcc-4225-b048-d6a0217848a9.png">
### Requirements

- A Mac running macOS Venture (13.0)
- Jamf Pro Account that has the following minimum persmissions
  - Send Computer Remote Command to Install Package
  - Read - Computers
- The Apple MDM Framework has to be still present on the Mac
- The serial number of the effect Mac

If successful, within the management history of that device you should see a InstallEnterpriseApplication MDM command.

<img width="1282" alt="history" src="https://user-images.githubusercontent.com/29920386/211600803-88c253bc-0ff1-4ced-a753-c6151ceae58c.png">

