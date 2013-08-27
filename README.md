ThatPDF [![App Store](http://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.png)](https://itunes.apple.com/us/app/thatpdf/id682246039)
=========


View, sign, and annotate your pdfs and other documents in ThatPDF.

ThatPDF is the central place for everything you need to do with your PDFs:

* View pdfs large and small in the highly performant built-in viewer.
* Quickly find what you're looking for via thumbnail views.
* Finalize contracts with signature and text annotations.
* Communicate revisions with marker annotations.
* Import pdfs from Dropbox, Box, GoogleDrive, SkyDrive, Gmail attachments, and Github.
* Manage your documents with an intuitive and capable document library

Plus, ThatPDF integrates with [Ink](https://inkmobility.com), so you can sign and annotate pdfs from other applications in just a few taps. You can also take documents from inside ThatPDF and launch them into other apps, like Evernote, Mailer, and your cloud storage.

The full list of features is detailed in our [blog post](http://blog.inkmobility.com/post/59031713981/thatpdf-a-simple-way-to-annotate-and-sign-pdfs).

ThatPDF is also currently available on the [App Store](https://itunes.apple.com/us/app/thatpdf/id682246039)

![ThatPDF in action](http://a5.mzstatic.com/us/r30/Purple6/v4/a1/e9/79/a1e979a2-7cc9-97c3-875d-7f5282cb94a9/screen1024x1024.jpeg)

License
-------
ThatPDF is an open-source iOS application built by [Ink](www.inkmobility.com), released under the MIT License. You are welcome to fork this app, and pull requests are always encouraged.

Much of this app is built off the excellent iOS PDF Viewer by Julius Oklamcak - [Reader](https://github.com/vfr/Reader). Reader is also open-source under the MIT License.

How To Contribute
-------------------------
Glad you asked! ThatPDF is based on the [Git flow](http://nvie.com/posts/a-successful-git-branching-model/) development model, so to contribute, please make sure that you follow the git flow branching methodology.

Currently ThatPDF supports iOS6 on iPads. Make sure that your code runs in both the simulator and on an actual device for this environment.

Once you have your feature, improvement, or bugfix, submit a pull request, and we'll take a look and merge it in. We're very encouraging of adding new owners to the repo, so if after a few pull requests you want admin access, let us know.

Every other Thursday, we cut a release branch off of develop, build the app, and submit it to the iOS App Store.

If you're looking for something to work on, take a look in the list of issues for this repository. And in your pull request, be sure to add yourself to the readme and authors file as a contributor.


What are the "That" Apps?
-------------------------

To demonstrate the power Ink mobile framework, Ink created the "ThatApp" suite of sample apps. Along with ThatPDF, there is also ThatInbox for reading your mail, ThatPhoto for editing your photos and ThatCloud for accessing files stored online. But we want the apps to do more than just showcase the Ink Mobile Framework. That's why we're releasing the apps open source. 

As iOS developers, we leverage an incredible amount of software created by the community. By releasing these apps, we hope we can make small contribution back. Here's what you can do with these apps:
  1. Use them!
    
  They are your aps, and you should be able to do with them what you want. Skin it, fix it, tweak it, improve it. Once you're done, send us a pull request. We build and submit to the app store every other week on Thursdays.
  
  2. Get your code to the app store 

  All of our sample apps are currently in the App store. If you're just learning iOS, you can get real, production code in the app store without having to write an entire app. Just send us a pull request!

  3. Support other iOS Framework companies
  
  If you are building iOS developer tools, these apps are a place where you can integrate your product and show it off to the world. They can also serve to demonstrate different integration strategies to your customers.

  4. Evaluate potential hires
  
  Want to interview an iOS developer? Test their chops by asking them to add a feature or two a real-world app.

  5. Show off your skills
  
  Trying to get a job? Point an employer to your merged pull requests to the sample apps as a demonstration of your ability to contribute to real apps.


Ink Integration Details
-----------------------
The Ink mobile framework adds the ability to take PDFs from within ThatPDF and work with them in other applications. Plus, ThatPDF can accept documents via Ink, so you can use ThatPDF to view, sign, and annotate PDFs. ThatPDF integrates with Ink in several locations:

  1. [ThatPDFAppDelegate](https://github.com/Ink/ThatPDF/blob/develop/Classes/ThatPDFAppDelegate.m#L122) registers incoming actions, namely view, annotate, and sign.
  2. [LibraryDocumentsView](https://github.com/Ink/ThatPDF/blob/develop/Classes/LibraryDocumentsView.m#L409) binds Ink onto the thumbnail views of the documents so that they respond to the two-finger double-tap gesture.
  3. [ReaderViewController](https://github.com/Ink/ThatPDF/blob/develop/Sources/ReaderViewController.m#L354) binds Ink onto the full document view, as well as responding to toolbar events that launch Ink.
  
Contributors
------------
Many thanks to the people who have helped make this app:

* Brett van Zuiden - [@brettcvz](https://github.com/brettcvz)
* Liyan David Chang - [@liyanchang](https://github.com/liyanchang)

Also, the following third-party frameworks are used in this app:

* [Ink iOS Framework](https://github.com/Ink/InkiOSFramework) for connecting to other iOS apps.
* [Reader](https://github.com/vfr/Reader) for viewing PDFs, as well as overall app structure.
* [Apptentive](https://github.com/apptentive/apptentive-ios) for receiving user feedback.
