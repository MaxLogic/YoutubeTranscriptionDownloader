---
url: https://www.youtube.com/watch?v=-usC5ADwRkM
title: Mobile apps on Replit: Deep dive & tech walkthrough
channel: Matt Palmer
created: 2026-01-27
uploader: Matt Palmer
view_count: 4577
like_count: 155
comment_count: 19
description: Try out matty stack: https://matty-stack.replit.app?utm_source=Matt&utm_medium=youtube&utm_campaign=mobile-apps
Template: https://replit.com/@matt/matty-stack?v=1?utm_source=Matt&utm_medium=youtube&utm_campaign=mobile-apps

Complete guide to building, deploying, and troubleshooting mobile apps on Replit using Expo and React Native.

00:00 Intro
02:33 Mobile workspace
05:24 Native vs web
08:13 Architecture
09:58 Publishing
22:05 Tech stack breakdown
28:02 Debugging
39:35 Tips & tricks

X: https://x.com/mattppal
LinkedIn: https://www.linkedin.com/in/matt-palmer

#Replit #MobileDevelopment #ReactNative #Expo #AppStore #VibeCoding #NoCode #AI #Programming #iOSDevelopment #AndroidDevelopment

What challenges have you encountered building mobile apps, and which deployment option (Expo Go, TestFlight, or App Store) fits your current project best? Share your experience in the comments below.
---

Today we're going on a deep dive into
mobile apps on Replet. And in this
video, we're going to talk about
everything from how to build and deploy
a mobile app on Replet to what it really
even means to deploy a mobile app,
right? Are you sending it to the app
store? Are you putting a server online
that your apps can access? We're going
to talk about that. We're also going to
break down how all of this works. So,
this video is going to be a little bit
longer. You can jump around with the
timestamps, but the goal is that by the
end of the video, you understand
everything you need to know about mobile
development. And that includes
technologies like React Native, Expo,
Expo Go, if you've heard any of these
terms, as well as what it means to
develop for a mobile device versus to
develop for a web application. So,
you're going to understand all of that
by the end of this video. And then at
the end, I'm going to talk about
troubleshooting tips and tricks to save
you some time, how I think about
building with mobile. I'll even share
some templates, some uh example mobile
apps that I've built that you might find
useful. Um, so let's just jump right
into it. So the really great thing is
that you build mobile apps the same way
you would build any other app on
revlet.com and that's from the prompt
box on the long homepage. So if you're
new, if you've never used Replet before,
Replet is a website that allows you to
take your ideas, turn them into
applications, and it happens all in your
browser. So under the hood, we're going
to be writing code with our AI agent,
but you don't really even need to know
about the code. And so in this deep
dive, I'm going to talk about all the
nuances and intricacies of the apps that
we'll be building. This will be a power
user walkthrough. But if you're new to
Replet, take a look at some of my other
videos uh to get the fundamentals. I'm
frequently going to reference, hey, this
is just how things work in Replet. So
just a heads up from the homepage.
You'll notice that we have uh build and
plan modes. I often like going into plan
mode when I'm starting some larger
ideas. I think that's also um worth
advising here as well. And there's also
this auto toggle. Now, if you say I want
to build a mobile app that does
something, a mobile app that you know
tracks, I don't know, habits, we're
going to like uh automatically pick the
best app for you. So, we detect this as
a mobile app and switch it over. You can
also just select mobile app. So, when I
show you the mobile apps uh that I've
built here in a second, those were built
with this mobile app stack selected. Um,
so just like that, if I was going to go
through the build flow, I might say,
"Hey, make a mobile app that tracks
habits. Enter into plan mode. Robot's
going to help me plan that idea out
before it jumps into building the
stack." Um, what does a fully built
mobile app look like? This is a good
example. This is called Maddie Stack
because a stack is just a set of
technologies um that you can build with.
And this is a sample like design
application that I built to kind of show
people um some some design uh sort of
feats you can accomplish using our
mobile stack. So I wanted to test out
some typography. I wanted to build out
some different components and make them
all themed in the same way. And I'm
going to talk about exactly the tools
that I use to get this output. Um but
really what we're going to do is we're
going to break down what's going on
here, what's the same and what's
different from the replet you know and
love. So, if you've used Replet before,
you know this uh preview pane here is
usually a website. Instead of a website,
now we're showing you a mobile app. And
this truly is a mobile app. It's built
with a technology called Expo and React
Native. We're going to get into all
that, but the things that are different
about the workspace is now you see a
mobile preview. And you can see the same
preview on your phone by scanning this
QR code after you download the Expo Go
app. So Expo is a framework that allows
us to build and ship these mobile
applications. And the Expo Go app allows
us to view this compiled code on our
device. So if you haven't give Expo Go a
download and then it's as simple as
scanning this QR code and what you'll
see on your device is that our app opens
up and then there's some loading that
has to happen. We'll talk about what
that process is. And then we get our
app. Now the app works exactly like an
app that would live on your phone does
and you can interact with it. I have
haptic feedback here, so I can actually
feel the interactions on the keyboard,
which is super nice and satisfying. Um,
and for all intents and purposes, this
is a mobile app on our device. It's just
not installed through the app store, and
it's ephemeral. We can't persist
information. We're not storing data, um,
etc. So, it's kind of a hack to be able
to view your the app on your phone this
way. It's not really a hack, but this is
the Expo Go development process. Um,
there's one thing that I want to really
call out here that should be evident in
this video, and that's that this has
this app has a different styling on the
bottom tab there, right? Like we're
using the actual iOS 26 glass effects,
which is cool, but it brings up an
important point, and that is the
difference between native styling, and
when I say native, I'm going to say
native a lot in this video. Native just
means the iOS SDK, the Apple native
styling, um, and web styling. So on web
we have just this kind of vanilla uh
toolbar here. Uh whereas on native iOS
we get this nice glass view but that's
enabled by the native SDKs the iOS SDKs.
So that's important. It's an important
difference and it ties in very closely
to what React Native as a framework is.
So we're going to talk more about that.
So, we started talking a little bit
about how the workspace is different
with this expo approach and hopefully
you can see right instead we're showing
a mobile view. Under the hood, we're
using some different frameworks. What
else is different? If you go to the
console, you're going to see two
processes uh running. First, there's a
server that's running. And second, our
Expo app is running. And so, the Expo
app shows us the same QR code. We could
also scan this QR code to have the app
on our device. It also powers what we're
seeing here, the front end. You could
think about this kind of like a client.
Right now, what you'll notice is if I
refresh that, we actually might have to
be a little bit quicker here. You're
going to see the app rebundle on the
home screen. And you can also hit R in
the console, I believe, to rebundle that
application. Now, what is bundling?
Bundling is Expo taking all the code
that we wrote, compiling it, and pushing
it to your device as native code. So,
we're actually sending different code to
iPhones, to Androids, and to the web.
This supports Android as well. React
Native, web, iOS, Android. There's a lot
of hate out there for green bubbles
versus blue bubbles. I have an iPhone,
but you know, like I I'm accepting of
everybody. I'm just I'm here for the
people. So, Green Bubbles, I'm here for
you. Android, I'm here for you. A lot of
the processes in this tutorial will
follow exactly the same steps. I'll call
out if they don't. Um, but this is
crossplatform. Just want to make that
clear. Uh, so we're bundling this code
up for the different platforms and
pushing it. And what that means is that
you might see a slight delay, right?
Like if I stop and I start this, it
might take a second for the what's
called the Metro Bundler, which is a
technology that that bundles these
languages up to start and for our app to
initialize. That's normal. And if you're
starting this for the first time, it's
going to take a lot longer. That's
because there's some pretty aggressive
caching going on here. Caching is just
saving data to speed things up. So like
on this app, it's caching data for our
app. Maybe that's the packages code so
that it starts up faster. Where you get
into trouble is if you change a lot of
things, the cache can become invalid.
And so in our troubleshooting section,
we're going to talk about strategies for
working through that. But for now, we're
just talking about the differences in
the replet workspace and how you can use
these tools to your advantage. So what I
wanted to show you was the console. And
I also wanted to point out there is a
server running. What does that mean?
That means that you know everybody loves
Rebellet because it builds fullstack
apps, let you have databases, lets you
do a lot of really complicated fancy
stuff. It's no different here. But when
we deploy these applications, we're
deploying a server that lives in replet
in the cloud and we're we're shipping an
app to the app store that then can
interact with that server if we want. So
as you're building your apps, start to
think about this this sort of
architecture, the way you organize
things. And the way I describe that is
uh when you publish an app, you're going
to have a version that goes to replet.
You're going to have a piece of code
that goes to Replet and that's the
server. And the server will give you
access to all those same things that
that you love from Replet, right? You
could have a database that lives in the
cloud. You could have AI integrations
that like process uh data. Um and you're
going to have an app that goes to your
users, right? So you'll have a native
app on somebody's iPhone. That means is
you can get kind of fancy with what do I
want to happen on the iPhone and what do
I want to happen in the cloud. And now
we're just getting into software
engineering, right? Like the fun thing
about replet is like you're just a
software engineer. I don't want to tell
you you're a software engineer because
that can be scary. It can be
intimidating, but it's exciting because
like you get to do really complicated
cool stuff like build out sick
architecture diagrams and talk about
running things in the cloud. It's just I
I can't believe we're living in this
era. It's outstanding. So, um we're
going to talk about what happens when
you publish apps like this. And I'm
actually going to I'm actually going to
shut this app down and we'll republish
it. We'll go through the publishing
flow. So, publishing an app, going
through this publishing flow, this does
not mean shipping it to the app store.
That's the second step. The first step
to publishing your app is that we're
going to actually just ship it to a
preview page like this so that anybody
with Expo Go can scan the QR code and
have access to the app on their phone.
You might be saying, Matt, I came here
to put apps on the app store. Why are
you giving me this nonsense? You have to
download Expo. First, don't talk about
Expo like that. I love Evan. Evan Bacon,
a founder of Expo, dude. Dude's name is
Bacon. Like, that's awesome. I love the
Expo team. This is amazing. What this
enables is rapid prototyping. So once
you get to your app to the way you like
it, you know, this is my kind of preview
app for design systems. Um I can come
over here and I'm going to publish this.
Again, we're going to take care of all
the publishing stuff for you. We're
going to build that app, push it to our
website, and I'm going to have this nice
little page where anybody can go and
interact with that. This is perfect for
prototyping. So, say you're a designer,
you're a PM, you're a CEO, you're
running a company. Your job isn't to put
this thing on the app store. Your job is
just to show people your vision. You can
build that out, deploy it on Expo Go and
share it with all your friends, share it
with your investors, share it with, you
know, somebody you're trying to pitch an
idea. If you pull up to like a pitch,
you know, you're trying to to show
somebody something and you say, "Scan
this QR code," and they have an app on
their phone, that's going to speak a lot
louder than having a slide deck, right?
So for prototyping, the fact you can get
something on people's phone is already
super powerful. So that's the first step
and that's how publishing works. Now
it's also important to mention what we
talked about here. When you click the
publishing button, if you have a server,
we are also deploying that server. So
this gets published. These are live.
These get published as well. So when you
publish, it's visible to not just you
but anybody else. And that's important
to mention. So in development, right,
when we click start app, the QR is in
the console that's visible to you. You
can scan it. You can interact with it.
You can interact with it across your
devices. When you click deploy, we're
creating a public URL with a QR code
that's now accessible to anybody with
Expo Go. So we have to be concerned with
privacy here and just cognizant of how
that works. And when we publish it to
the app store, we're undergoing a formal
submission process to Apple and Google
and anybody can install that app and
engage with it. So kind of three levels
of deployment there. Now one other thing
to mention which is pretty cool, right?
We talked about developing this
application here in Replet which is
running in the cloud. It's an
environment. We also have the replet
mobile app. We'll pull that up on the
screen. The app is going to be synced
right to our mobile app. So if I go over
to this this application, if I open it,
um this is running not on my phone. It's
not running on my desktop. It's running
in the cloud. So this environment is a
mirror of what you see in the workspace,
which means that say I wasn't at my my
laptop, say I'm in like a lift or an
Uber, I can click open in Expo Go and we
can get the exact same application. And
that's because this this app that I'm
interacting with here under the hood,
the server, like the the hosting service
that's powering this is Replet. So you
can build native applications for your
phone on your phone, right? So, I think
that's outstanding. You can just prompt
agent go into all this stuff. Um, really
really cool stuff. I I've [snorts] never
seen anything like this before. So, I
prefer desk like this is this is hard.
It's hard to stand these apps up, but
for quick prototyping, getting stuff out
the door, you can build it on your
phone. Um, and that's that's really
special. Uh, and I haven't seen really
anything like that before. So, our app
is still publishing. the initial version
takes a little bit longer with React
Native because we're building three
versions of our app simultaneously,
right? Web, iOS, Android. What I want to
talk about now is is what it means to
submit something to the app store
because I think that this is important
to clear up. Um, and I want to level
set. I want to set some expectations.
Um, and then we're actually going to go
through the flow because we've made it a
lot easier. So, submitting app store
apps is really hard and it kind of is a
pain. You have to pay some money either
to Apple 100 bucks a year to Google like
25 bucks takes a couple days to enroll
uh for Apple it takes a few days to have
things reviewed and there's like a
pretty high like level of strictness
from the Apple review team. They're
probably not going to like us after this
whole thing because we're sending hella
apps through the app store now. But uh
Google Play is a little bit more
lenient. You can get more stuff on the
app store. So unfortunately it is not a
you're going to deploy something today.
If you're trying to deploy an iOS app,
you actually have to sign up for a
developer account which takes a a day or
two. You have to go through this process
which takes probably like a week. Um but
you can build that app out today
immediately. So it's still difficult to
submit things to the app store which is
just kind of a fact of life but we've
streamlined the process to make things
as simple as possible. Now, the other
thing that I want to call out is that
building an app, getting an app on the
app store is actually about more than
just writing code, right? And that's
this little toggle I have down here that
we're going to talk about. It's actually
uh making an icon for your app, getting
those different sizes all figured out.
Expo can help you with that. Um, Replet
Agent can help you with that. It's
taking screenshots of the application
for different devices and different
sizes and showing off all the features
and thinking about marketing and
thinking about product positioning and
all these things. It's getting your
privacy policy up. It's uh making sure
that the description is good, that the
keywords are good, that the categories
are good. It's making sure it's
appropriate for different uh types of
people, maybe kids if you're making it
for kids. It's making sure you have your
contact information set up and your
Apple developer account set up and all
these things. So, there's a lot that
goes into it. We're going to talk
through that. But, I think a lot of
people saw just how easy it was to build
apps on Replet and they thought, "Oh,
I'll just submit something in the app
store this afternoon." No, there's
there's a lot that goes into it. So,
these are all things that we have to
kind of think through as we're building.
Um, it's kind of part of what it means
to be a builder. And as AI gets better
at writing code, we learn there are more
there's more to building. There's more
to shipping than just writing code. So,
let's take a look at our app and uh
we'll see if that publishing is is all
wrapped up. So, you can see the app is
live now. Um, and if I click this URL, I
go to my preview page. The benefit of
scanning this QR code is that it will
load on my device a lot quicker. it
doesn't have to get built and it will be
active even when my Replet app is not
running. So that's what the publishing
quote unquote publishing process looks
like on Replet for this design app which
I'm going to make available to you guys.
Link will be in description. Now once
you're done with this publishing
process, you can push it to the app
store. So we're going to walk through
that. We're going to talk through how
this works and then after that we're
going to really dig into some more
advanced functionality. So clicking
start publishing to the app store is
going to prepare our app. This takes a
few minutes. Under the hood, we're going
to be using an expo feature. Uh that's
going to expedite what this publishing
process looks like. So once this is done
preparing, we'll jump back into it. All
righty. So Expo launch is now open.
That's Expo's product for shipping to
the app store that we use. It's inside
Replet. You don't have to sign up for
anything additional. You can just use
Replet. It's pretty great. We're going
to walk through it. So, my app Matty
stack because it's my tech stack for
building mobile apps. My slug. Um, we're
going to continue with that slug. Uh,
and under the hood, what Expo is doing
is it's creating a project for us. Now,
we're going to sign in with Apple. Um,
this is where I blur the screen and type
in my Apple details. I'm going to skip
this screen. Uh, you got to put in your
Apple developer email and your developer
password. And you have to trust me that
this is very secure and we're not
exposing any information. The folks at
Expo know exactly what they're doing.
Um, you have to sign up for the Apple
developer program. So, this is where you
have to pay Apple money. Uh,
unfortunately, so I'm going to fill this
information in. I'll jump back with you
after this step. All righty. So, we
signed in with our Apple account and now
I'm asked to choose an Apple app. So,
this will be a new app. Um again app
that I built here is more of a design
preview. It's uh sort of experimental.
I'm calling it Maddie stack and the
bundle identifier typically for apps is
uh the website that you have just your
website uh reversed. So if it was
mattpalmer.com it would be
com.mattalymer. My website is
mattpalmer.io. So I'm doing
io.palmer.mmattystack.
This is a unique bundle identifier.
Again that's just convention. You can
really kind of call it whatever you want
but you can't change that later. So,
call it something good. So, then we're
going to click create app. Under the
hood, what Expo is doing is setting this
app up for us with Expo services, tying
it to our account. Um, and then there's
some other kind of launch uh
configuration steps that you can set up
here. So, launch to testers. Um, this is
uh good because then you can have it
open on test flight. You could like
install it right away. So, there are
different levels of installing your app
to the app store that we'll talk about
in a second. But finally, you just click
launch to the app store. And now you're
kind of off to the races. What Apple
what Expo is doing is it's using our
Apple account. It's using all this
information that it has for us to
promote that to the App Store. Again, I
made this look simple, but it's also
because I'd already set up an Apple
developer account, which takes time. And
then second, Apple's going to have to
review your app. Hopefully, there are no
infractions, etc. If you were launching
it to the Google Play Store, that would
be um a similar process. So once um
that's all done, it's going to kick us
back to replet. Uh and now the app's
being published. The apps are really
just like that. Now again, your app has
to undergo reviews. I'm just going to
keep talking about that. It has to go
through all these things. There's a lot
of stuff you're going to have to do to
get it set up on the app store, but
you're well on your way to having it
published. So this publishing process on
Replet typically takes around 45
minutes. Replet will notify us if we
have the Replet app uh installed once
that's done. But I really want to drive
home the difference between uh
TestFlight and the full app store uh for
you quickly because there are reasons to
just put your app on TestFlight. If
you're building something just for
yourself, just for your friends and
family, TestFlight is a really good
option um because there's a lot of
responsibility if you're putting things
on the app store. Okay, so we actually
took a couple hour break here. Apple's
App Store Connect, the platform we're
going to go to, was down for a few
hours, but it's back. And so now we can
take a look at what happened when we
published our app to the store. So if we
click this link, we're going to get
dropped in App Store Connect. Uh, and
now we have uh sort of the submission
portal for our app. So this is kind of
the staging area where you can add
screenshots for iPhone, maybe iPad if it
supports it. Uh, promotional text, the
description, keywords, support URL,
marketing URL, copyright,
lots of stuff. Uh there's a lot of
things to polish, lots of stuff to do.
So this is kind of the final step before
then you'd add your app for review. And
just one other thing to call out. Uh
this would make it live to everyone. You
also might consider using TestFlight
just to make it live to yourself or to
share it with friends and family. Again,
TestFlight's a great option because you
don't have to go through that approval
process. It's a bit faster. So I'm going
to keep plugging TestFlight. If you're
on the Google Play Store, you'll see
probably some similar submission
process. Um and that's kind of where the
the Replet tutorial ends. end to end.
This is where you'd go pick up uh on the
App Store connect process um and
continue with Apple. If your app
changes, you're updating code, you'll be
able to republish that um by going
through the republish flow, submitting
the code again. It'll go through the app
store. There's a separate update
process, but it's still linked with Expo
launch. So, end to end, that's what the
process looks like. And I tried this a
year ago. It was really tough. It was uh
a lot harder than it is today. Um, and
so it's been really cool to see how far
this has come, even if there are still a
couple headaches that we have to get
over on the app store submission
process. So, Expo Go, we talked about
the QR code is a development previewer
of our app. Anybody with Expo Go can
scan the QR code. They don't need a
developer account. Uh, there's no review
process and it's great for prototypes.
Test Flight or internal testing allows
us to actually install that application
onto our phone. So, we get benefits of
like being able to save data, being able
to reaccess the app, not having to have
an Expo server or deployed app kind of
running all the time. You can invite
testers to download the app through
email. Uh, and you do need a developer
account to get this done or to go
through expo launch. And it's great for
um beta testing because there isn't as
much review. Like Apple's not going to
be giving your app as much scrutiny
through TestFlight as it would through
the App Store. to to wrap that up,
right? The public app store, anybody can
access it. They search in the store to
download it. You need a developer
account. Yes. Um there is a full
thorough review. Uh you have to go
through all of Apple's hoops. Um and
it's best for production. So this is
like once you have that polished app,
but if you're just trying to get
something out the door, test flight
could be a really good option. So don't
write that off. Okay. So now this is
kind of my favorite part. This is why I
love doing what I do. I'm going to break
down how all of this works for you in
hopefully a digestible way if you're new
to mobile development. And then we're
going to talk about strategies for
managing um all of these tools. So, in
this section, we're going to talk about
like why this is an amazing achievement
in the first place. But we're also going
to talk about the stack um and how I
make the most of this and improve um on
what we're doing already. So, if you've
built web apps on Replet before, you
probably have heard of React. Maybe you
haven't heard of React or TypeScript.
Typescript is a variant of JavaScript,
which is a language for writing typed uh
code for building your apps. And typed
code just means that we're telling uh
the compiler, we're telling the computer
what types. Oh, is it an integer? Is it
a string? Is it a boolean? Right? Like
we're we're being more descriptive about
what we're building. So React is a
library or really more of a framework
for building apps on the web. A lot of
the apps that you go on the web were
built using React. Creator of React
actually works at Replet. Amjod CEO of
Replet also worked on React.
React is just a framework for writing
JavaScript or TypeScript. React Native
use the same React concepts but is for
mobile applications and web apps as
well. So React Native compiles all that
code to a web version, to an Android
version, to an iOS version. And so the
mental model between React and React
Native, it's actually identical. And
maybe that's why AI is good at writing
both. And so Expo,
Expo is a framework that uses uh React
as a base, React Native as a base to
build apps for iPhone, web, and Android.
And as you've seen in this demo, it
makes the process a lot easier. So this
is the the little model that I wrote up
that maybe helps explain things. At the
high level, you and replet agent write
the code. That's all you're really
exposed to, right? And your app exists
as code. So, Replet agent writes this
code. You are using uh Expo in your
codebase. Expo simplifies React Native,
which is a framework and simplifies the
process of us shipping it to the app
store. And React Native allows enables
or simplifies the process of building
for iOS, web, and Android in parallel.
That's a mental model to think of what
the heck is going on here because
there's a lot of stuff. But really the
things that you're going to be
interacting with mostly are just replet
agent and then we're going to have to
understand some of the intricacies of
expo as we start to debug things and fix
some of these problems. So the
alternative let's talk about what if we
weren't using expo if we weren't using
replet what will we have to do? Well, if
you want to develop on iOS, you'd have
to install Xcode, learn to write Swift,
which is like Apple's thing that's
really hard. Um, set up a really
complicated development environment on
your laptop. And I'm not kidding. Like,
this would be something that took me I'm
a former developer. Took would take me a
while to figure out. Um, Xcode breaks
all the time. I know this because I've
tried to to do some similar things. Um,
and they're really complicated. Like
there are that's why when you hear of
like an iOS developer, they just spend
all day building iOS apps. Expo is
complicated. Android Studio I would
assume is similarly complicated. The
learning curve is really steep. React
Native is just code. That's why it can
run in replet. It's just it's it's the
same technologies as React and
JavaScript and that's what make it
easier. You have this single shared
codebase. That's why like even the
Replet app is actually built with React
Native and with Expo. So we kind of were
using the same tools that we're showing
you all. The re the replet mobile app is
written once and then compiles to three
platforms. So it's much easier. So we
talked about that expo is a framework
that simplifies react native
development. There are two types of expo
runs. This is important. Expo go and
expo dev builds. So what we're using in
replet is expo go. We talked about expo
go a lot
here in the preview pane. This QR code
allows you to access expo go. The Expo
Go mobile app that you're interacting
with that allows you to see this is a
lightweight tool for previewing these
builds. Now, why is it lightweight? It's
lightweight because it actually doesn't
include a lot of the native libraries.
Remember, when we say native libraries,
we're talking about things like glass
styling or components that are built
into the iPhone that we're leveraging
for our application. It doesn't include
a lot of native libraries. That what
that's what makes it lightweight. Now,
the good thing about this uh is that you
don't have to install anything on your
phone. It's super fast. You don't have
to pre-build anything. The sort of
negative thing is that you're not going
to have access to native modules. So,
that means that when you're doing
research on functionality you want to
have in your app, you have to make sure
that it's compatible with Expo Go. That
gets important as we build out larger
apps, right? So, as you're starting to
build your app, as you're starting to
think of things when you're going to add
something really complex, this is where
you might have to say, should this go on
the server? You know, is this um is this
compatible with Expo Go? Go into plan
mode with Replet agent. Ask, hey, is
this thing compatible with Expo Go? Help
me understand um all these things.
Highly recommend it. So, that is like
the tech stack breakdown, right? We have
at the top level replet agent writing
your code. Your code is using Expo as a
framework that generates that that is
built on React Native generates platform
specific code for iOS web and Android.
As developers, we're using Expo Go to
interact with our application. Um that's
what's being serviced on the web. Um
under the hood, right, we talked about
uh what's actually happening and that is
that uh we have a server that's being
deployed on replet. You can have a
database and other AI integrations and a
client mobile app on your phone that
users can interact with. So you could
move all the the logic to your phone.
You can move more of the logic to the
server. That's really up to you. That is
the tech stack that's going on replet
when you're building these mobile apps.
And it's a lot and it's complicated and
that is mobile development and that is
software engineering. Um but hopefully
it's it's approachable. So last section
of the video here, we want to talk about
troubleshooting. I'm going to break down
how I develop with Expo Go. There's like
a lot of stuff to look out for, stuff
that can happen, just little paper cuts.
My goal as an educator is to save you
all the time that I have wasted learning
these things. So that's what I'm going
to do. Okay, so now we're going to do
some live debugging. I'm going to walk
you through a sample problem, something
that I've encountered as as we build
more. This starts to happen pretty
frequently and that's just kind of part
of mobile development. I opened up my
app and I got this crazy server error.
This is a different app that I'm working
on. It's for taking screenshots. Um, and
I was like, whoa, red text warnings, you
know, ah, don't don't freak out when you
see errors like this. It's actually
important. It's like, you know, uh, if
you get a research paper in college, you
open that research paper up, it's like
this could be kind of dense, a little
intimidating, but if you dig in, if you
like read the conclusion, the summary,
you can start to understand what's going
on. Start to read errors. This is really
important. Server error, none of these
files exist. Node modules. Okay, so
we're going to talk about what node
modules is in a second as we dig into
our debug debugging process. But what
this tells me is that there's something
wrong with the library expo SQLite. Now,
from my background in in uh data, I know
that SQLite is a um uh database format.
So, so I'm storing data on the app on my
phone and it's not working in the web.
And so my hypothesis was I bet this
actually works on my phone. And if I
open the app on my phone, it does work
on my phone. I scan the QR code. So, we
have a platform disparity between iOS
and web. and web can't handle this
SQLite interface that I might have asked
agent to put in on accent but mobile
can. So we're going to chat with agent.
We're going to say can you help me
understand
the error? And while we're chatting with
agent we're going to go over and take a
look at some debugging tips. So um
one of the constants in the way that
Expo works is that it caches things
pretty aggressively. We talked about the
build times. We talked about why it
takes maybe a second or two for things
to get started. And what we're going to
have to do as we debug things is, you
know, gradually reset some of those
caches. The thing I'm going to call out
is that agent can do all of these things
for you. So if you don't want to worry
about it, you just let agent rip. But if
you're like me and you're a little bit
more curious, you want to learn about
how these things work, these are the
troubleshooting steps that I would take
to start to diagnose problems with my
application. So say you're seeing that
scary screen on web or on your phone.
Here's what we're going to start. Um, so
first, if changes aren't showing, you
can try shaking your phone, which sounds
ridiculous, but that's actually the expo
trigger um for reloading the app. So,
you can see this reload dialogue. I
click reload, and it's going to
redownload the bundle. Um, the same
thing you can do on web by tapping R in
the console. So, if I hit R here, what
you'll see is that it rebuilds, it
rebundles the application. We're getting
the same error. um that is going to be
kind of like our first line of defense
if we see something that's not working
and agent doesn't know what's going on.
From there, we're going to start to
escalate and do um uh maybe more
invasive things to start to to try and
clear that cache or reset things. So,
let's see what agent is saying for our
error. Exposite is not working on the
web platform. Um, this package which
works on iOS devices uh has limited web
support trying to load a file that's
breaking. Okay, cool. Uh, so you're
seeing that the iOS bundle succeeded and
it works on actual mobile devices. The
web version requires special web
assembly. That's advanced. The solution
would involve making the SQLite storage
code only load on native platforms with
a different approach for web. Okay,
currently I'm actually focused on mobile
development, so I'm not that concerned
about web. What I'm going to say here is
um can we gracefully
fail on web? Uh so I can still see the
UI and um we omit
that functionality.
So what I'm saying is, hey, actually,
because my app works on my iPhone, I'm
developing for iPhone, I'm not that
concerned about the web. What we can do
is actually just say, you know, we're
going to shelf this functionality for
now. And that's what I'm asking agent is
like, maybe we just don't build this
thing. We don't necessarily need parody.
It's something we can address down the
line. That's part of engineering as
well. It's kind of making decisions like
these. So we'll see what agent says. But
as we think through this these um these
steps,
it looks like agent's going to come up
with a plan for for doing just that. So
we can start building this. And we're
going to talk about the rest of the
steps in here because I think that
they're u they're important to discuss.
Um so uh if we head over, the first
thing we can try is shaking and reload
loading. And the second thing is
clearing the cache. You're going to see
agent debug these steps. So again, if
you're bumping into errors like this,
you can kind of rely on agent to take a
first pass. But it's good for us to know
how to do them as well. The cache is uh
a cache is really just stored data to
make operations, repeated operations
faster. So what Expo is saying is, oh,
there's all this the these steps in the
building process. I'm going to store
some of that information away. I'm going
to keep it handy so that when we do it
over and over again, I can access it
faster and the process is speedier.
Sometimes it gets corrupted or bad
things happen and the cache um is
invalid and it breaks our app. The way
to clear the cache is expo start clear.
Um, and that clears the cache. So for uh
escalating, it's first we're going to
shake to reload, then we're going to try
clearing the cache. Uh, and the way that
we do that
is by going to the shell.
And if you want like a really quick way,
you just run npx expo start- c. That's
going to start our app. Uh, and we'll
get like a little port warning. You can
just say um, whoops. You can say yes,
not no. And
now the cache is cleared. So, um you can
actually just cancel that process and
just know that the cache was cleared on
that run. And the next time that your
app starts, you're going to see that
Metro Bundler uh say that the cache is
cleared, right? So, you'll get this me
message bundler cache is empty
rebuilding.
If you want to like just test your app
in a constantly cache cleared state, you
can just drop a C in on the expo dev
command like we just did. So you see
this this expo dev that just runs the
command that we said um and adding a C
to this command will clear the cache on
every restart. So I was in a state where
things were broken. I was clearing the
cache a lot. I just said, hey, every
time agent restarts the app, I want the
I want the cache to be cleared. So
that's one way to approach that. So
what's next? Say you try clearing the
cache, you're still getting some weird
errors. Reinstalling packages is the
next step. So deleting node modules on
uh JavaScript apps effectively
reinstalls the package. So um I'm using
bun which is a package manager. By
default, agent uses npm. As you get into
web development, as you get into mobile
development, it's good to learn the
differences between packages. What mpm
is, what bun is, why you might use one
over the other. In this app, I'm using
bun. So what I can do is I can say rmrf
node modules. That's going to delete the
node modules folder which again is just
our um packages and then I do a bun I
and that's going to install the
packages. So node modules caches a bunch
of stuff as well. We're clearing that
cache and we're reinstalling packages.
That's another way to start debugging
your application. There's also this expo
file in your app.expo.
If you don't see dot files here, you
might have to to click the three dots
and say show hidden files. But what we
can do now is say rmrf.expo,
right? And that's another thing that we
can clear out. And we're going to see
that in kind of our final option here,
uh, which is full nuclear.
And I'll link this in the video
description, but all this really is
doing is removing, uh, node modules. By
the way, if you somebody ever gives you
a command to copy and paste in your
terminal, always really think through
what you're about to do before you run
it. So, always use caution. What we're
going to do is we're going to remove
node modules, delete all those packages,
remove the exppo folder, run an mpm
cache clean. So, we're cleaning the
cache of our package manager. Uh, and
we're we're forcing that. And then we're
reinstalling packages and restarting the
app with a cleared cache. So that's
exactly what we were going to do before,
right? This is exactly the same thing.
So um this nuclear option is just really
going through and making sure that uh
we're removing all cache files, anything
that could be causing a metro error. So
that is kind of the next step. And um
those are my debugging tips if you're
starting to bump into issues. Again,
what I find on mobile is that really
shaking uh and redownloading will clear
that uh clear that download, force a
redownload. That can be useful. Um if
agent fails to clear the cache, you can
clear the cache. If agent fails to
uninstall these packages, these are good
things to know about. What are some uh
other tips? Um so I talked about
pressing R, talked about expo start
clear. Expo doctor is a useful one. As
your app gets more advanced, you're
probably going to have packages that you
want to upgrade or you might have
version mismatches. running npx expo
doctor um is going to run expose doctor
as the name would suggest to run checks
on your project and make sure it's
valid. Then it might say, hey, you have
versions that are like out ofd um you
have uh some other stuff going on. Um
and you can run this command maybe to
fix it. npx expo install check. So don't
just run this command. My my call out
here is don't just run npx expo install
check because you're like, "Oh, I just
need to need to update these packages or
I need to downgrade these packages." You
should only change packages if there's
an intentional reason to do so. You
don't just want the latest version of a
package. The reason for that is that um
you can think of all of the packages,
the libraries in your folder as their
own particular environment. And it's
really important that um you maintain
that environment and just updating
packages can actually break your
runtime. So only upgrade packages if you
need to or if there's a security
advisory because you're going to open a
whole another can of worms if you just
force update packages. But Expo Doctor
is really good if you're having problems
and you just want to see um hey is is
there something I'm missing here in my
Expo configuration that might be causing
the issue. All right, so we're back and
uh this one took a while and you can see
agent was kind of going to work here.
But what I want to call out was that uh
it did it removed node modules bin. So
it's actually doing what we did which
was removing uh cached files, removing
previously installed packages um and
clearing the cache for us. And
ultimately that got to my sort of
working screenshot uh app here which is
very in its very early days. Um but you
can get pretty grizzly, pretty gnarly
errors. Um sometimes they have to do
with package mismatches. Sometimes uh
they require you to take some action to
resolve them. That's normal. That's a
part of mobile development. Most of the
time agents going to be able to fix
them, but um these steps you can follow
along with to help resolve those errors.
And so I'm going to leave you with a few
other tips for better responses from
agent as you're building. Documentation
and patterns are really good advice. And
so as you build out uh your app, if you
can understand the frameworks that
you're using or even just understand the
patterns that you want to implement.
Hey, use reusable logic here. Think
about how we're building this thing.
Start to ask agent to write docs in your
app. Say save these off in the docs
folder, you know? So maybe you're saying
um something like uh save in docs
folder,
right? Um or skills, which maybe you've
heard about. We're going to be
supporting skills soon on Replet. Um, in
the meantime, you could install cloud
skills and reference those. You could
write these docs, write other sort of
documentation on how to use certain um,
libraries that you're implementing. Uh,
and lastly, think like an engineer. What
we just did, debugging, um, is thinking
like an engineer, and it's the process
of breaking problems down, working
towards a solution. I'm going to
continue to do my best to help you learn
how to do that. Um, and it's not easy.
It takes time to learn, but this has
been a full overview. the new mobile
functionality on Replet, how to take
your app to the app store, how to think
about debugging problems, what the heck
is actually going on, what Expo is, what
Expo router is, React Native, all of the
things. It's a long video. Thanks for
sticking around. Hope you learned
something and uh I'll catch you next
time. Peace.
