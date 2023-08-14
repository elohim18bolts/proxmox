# Proxmox - SPICE client setup for MacOS

1. Install a working (and compiled) version of [virt-viewer](https://www.spice-space.org/osx-client.html). You may view the homebrew package's upstream source on [GitHub](https://github.com/jeffreywildman/homebrew-virt-manager).

   ```bash
   brew tap jeffreywildman/homebrew-virt-manager
   brew install virt-viewer
   ```

2. Once that's installed should be able make a call `remote-viewer` with a _pve-spice.vv_ file downloaded from proxmox web interface
   ```bash
   remote-viewer pve-spice.vv
   ```
   Check out this [useful script](#file-pve-spice-sh) for debugging. There are also several other cli tools like [this one](https://github.com/Corsinvest/cv4pve-pepper) on GitHub that can be used to test the same sort of thing.

## Improving Quality of Life

We want remote-viewer to automatically start and open the session when we double click the VM entry in proxmox. To do that we need to first create a small helper application.

1. Launch `Automator` and select **Application** from the dropdown list, when prompted.

   ![Screen Shot 2021-07-15 at 1 39 31 PM](https://user-images.githubusercontent.com/12147036/125855643-40e5b959-66fb-406f-bec2-4099ebfdaf8c.png)

2. Search for `shell` and drag to the right. The contents:

   ```bash
   /usr/local/bin/remote-viewer "$@"
   ```

   Make sure to select `as arguments` for passing the input. Save as `~/Applications/pve-spice-launcher.app`.

   ![Screen Shot 2021-07-15 at 2 13 01 PM](https://user-images.githubusercontent.com/12147036/125858501-4227b034-91fd-42d5-970b-ccfe4ce437f1.png)

3. Locate a _pve-spice.vv_ file or any file with _.vv_ extension, and right click, and go to `Get Info -> Open With -> Change All`, look for the .app file you just made.

   ![Screen Shot 2022-02-16 at 11 26 22 AM](https://user-images.githubusercontent.com/12147036/154342602-87faada5-7441-41fd-8f2f-41e989a2a469.png)

4. In Chrome, click on the small arrow on the list of downloads at the bottom, and select "Always open files of this type"

   ![Screen Shot 2021-07-15 at 2 02 46 PM](https://user-images.githubusercontent.com/12147036/125857885-3f105b57-426e-4de8-b519-3bc4c7933e60.png)

5. If everything is set up correctly you should be able to double-click on the VM in the left pane of Proxmox and remote-viewer should start up and take care of the rest.

   Note: the _pve-spice.vv_ files will be automatically deleted by remote-viewer

   ![Screen Shot 2021-07-15 at 2 05 57 PM](https://user-images.githubusercontent.com/12147036/125858112-e6a8f27a-71b2-4950-80ae-19c7905b9db5.png)

   <img width="1131" alt="Screen Shot 2021-07-15 at 4 42 21 PM" src="https://user-images.githubusercontent.com/12147036/125871269-a3220fd3-7b54-430d-81ed-d5278abf3f4d.png">

Enjoy!
