---
url: https://www.youtube.com/watch?v=Vu_XOKKgJtA
title: Claude Code Can Make Videos Now (Remotion Guide)
channel: Alex McFarland
created: 2026-01-23
uploader: Alex McFarland
view_count: 16104
like_count: 326
comment_count: 27
description: 📬 Get access to assets and resources I discuss in my videos ➡ https://alexmcfarland.substack.com/

🚀 Build your own co-writer inside Claude Code ➡ https://alexmcfarland.ai/co-writer-system

---

You don't need After Effects to create motion design anymore.

In this tutorial, I'm showing you how I created a motion graphic for my landing page in 10 minutes using Claude Code—and I'm sharing the exact skill I use to get better results from the Remotion agent.

This is for content creators, newsletter writers, course creators, marketers, founders, and anyone who wants to add motion design to their content without learning video editing software or hiring a designer.

💎 RESOURCES FROM THIS VIDEO

Remotion X Announcement (8.3M views)

https://x.com/Remotion/status/2013626968386765291?s=20

Installation Commands:

npx skills add remotion-dev/skills
bun create video

The motion-design-prompt skill is available to my Substack subscribers.

---

#claudecode #motiondesign #remotion #aitools #contentcreation #videoediting #claudeai #anthropic #writingsystem #aiautomation #nocode #solopreneur #creatortools
---

Hey, what's up everybody? I created this
motion design graphic that you're
looking at right now in less than like
20 minutes using Claude Code. So, I had
to get in here and drop this video
because I'm genuinely blown away by this
this new capability of creating motion
design with Claude Code. So, you can see
this here. I'm going to show you exactly
how to do it. This is the full, you
know, 10 15 second design here. It
started off with this initial terminal
design that I then built out for a
larger like uh promotional video for my
coowwriter system. And the you know the
reason this was this is capable now is
from this company here remotion that
dropped an agent skill for building out
these motion designs in their like
studio. And if you're on X then you
probably saw this because it went super
viral I think yesterday. You can see
they have 8.3 million views on their
announcement video showing this motion
design that they created themselves, you
know, to promote it. They created with
this this skill, with this tool. Uh, you
know, they released a uh like little
video showing how they did it, which is
super confusing. They're super fast.
It's not really good. So, I'm going to
break that down for you today. And you
could see a bunch of people here sharing
the types of designs that they built.
Uh, be careful if you're on exo because
there's a lot of uh rage bait. There's a
lot of people who post stuff that's not
really designed with this. Um, but you
know, nonetheless, it's like incredible.
So, I'm going to show you exactly how
you can do that today. So, the first
thing you're actually going to have to
do is open up your terminal here. And
you can see on the X announcement here,
they gave us what to run here. So, we're
going to run this right here inside of
your terminal. All right. and it's going
to download the skill from the
repository that we need to use here. So,
you're running this just in your regular
terminal outside of any project as of
right now. You're going to see you got
this new remote best practices skill
best practices for remote video
creation. And then uh you get to choose
what agent. So, we're using Cloud Code.
Going to hit enter here. We're going to
install this on the project scope. All
right. Instead of globally and then
we're going to use the recommended
installation methods. All right, proceed
with installation. Done. It now
installed it. After you do that, you
need to run uh a couple more things
here. It's very simple. Just follow.
You're going to run bun create video.
Once you do that, it's going to open up
all these templates that Remotion gives
us. Honestly, I don't know what, you
know, some of these are. We have like a
hello world starter template. We have uh
recorder. We have, let's see, I don't
know, a bunch of still images,
audiogram, music visualization, stuff
like this. I see one for Tik Tok as
well. Generated, generate animated
wordbyword captions. So, I don't really,
you know, I haven't tried any of these
out. I just use this blank canvas here.
So, it's just, you know, a blank canvas.
And you're going to hit enter here. And
now, it's going to tell you a directory
to create your project. So, this is the
folder you're going to create a folder
to run this project in. So, for example,
what I'm going to do here is just call
it like uh motion design, right? And
then once you do this, you're going to
add the agent skills. And then this will
fully set up the project here inside of
that folder. And it's even going to ask
to open it in VS Code. You should
already have you should have VS Code
installed for your coowriter, cursor,
stuff like that. So, we're going to open
this in VS Code. And this is what it
opens up. So, I'm going to close these
out here. And this is the Remotion
project that's now opened up here inside
of VS Code. You can see on the left we
have all the different packages and
files that you need. So you're going to
see here on the left that we have like
aent.cloud.cursor.jemini.opencode
for whichever one you're using I guess.
And since we use or I use claude for my
entire writing system and operating
system here, I'm just going to delete
these uh these other ones that we don't
want like cursor Gemini open code. I'm
going to delete those to clean it up.
All right. And now we have our claude
file which you should be familiar with
if you build out uh you know cloud
systems. Here we have our skills. Now it
has the the agent skill from roototion
best practices. All right. And then we
also have everything else we need here
to start creating the motion designs. So
the first thing I want to do is I'm
going to show you inside of my own uh
claude folder and show you the whole
process that I did to create those
designs I showed you. and then I'll show
you how to start, you know, fresh and
create your own. So, we're going to
first go over to my coowwriting system.
All right. And here we are. This is what
my co-writing system looks like. And,
you know, one of the things I have
inside of my coowwriting system is I
have a deployments folder where I
literally have my landing pages deployed
online. So, if we come here to Google,
we have the coowwriter system. This is
the new motion design I put on my
landing page. But, you know, forget
about that being there for a second.
This is, you know, my coowwriting system
landing page that I had with all of this
these different images and different uh
graphics here. And what I wanted to do
was create these designs for this
landing page. So, the first idea I had
was to create this design that you're
looking at right here and put it inside
of my landing page. And you could see it
worked perfectly here. So, what we're
going to do is let me come back over to
my uh system here. And this is the
prompt basically that I used. So, I told
it like I told Claude that I wanted to
write me a very detailed prompt to
create uh you know a motion design for
my landing page and I pointed it to the
path of my landing page. And what we did
here was we created this this big prompt
a realistic computer terminal window
where a folder file structure types
itself out line by line that exact you
know uh design you were looking at. And
I got this really detailed prompt here.
All right. I took that prompt and we
went over to our motion design project
opened here that we just had downloaded
right from reotion. We downloaded the
skill and I showed you everything here.
So I came over to that and I started a
new claude session and I pasted this
prompt. All right. Once I pasted this
prompt, you can see that the remotion
skill the agent here in Claude started
working on creating this animation. It
it put a bunch of to-dos. it, you know,
it completed all the to-dos. All right.
And then I kept iterating and adding on
to it like little things that I wanted.
And this is what we came up with here.
We came up with at first this design
Claude created and it launches this
little studio on your web browser. So
you could see the first thing I created
was this terminal for my coowwriter
system kind of just showing what's
inside of it. Cloud.md file uh agents
and stuff like this. And then I kept
iterating inside of that clawed session
to finally get to this where it was like
a longer promotional video for the
coowwriter system which I keep talking
about it. If you don't know it's a
exclusive community training program and
and platform that I have. So I wanted to
build out this full one. So I kept
iterating on it. Now to make this even
easier for you to do I went ahead and
created a clawed skill that will help
you create prompts like this. So that's
what we're going to do now.
So, we're back here in that original
motion design folder at the very
beginning of the video that we set up in
our terminal and set up this new folder.
It's a completely fresh folder. And what
we can do here is open up a new uh
Claude session here. And before I show
you how to use the skill for prompting,
I want to just show you that you can
also just simply, you know, type out
things and talk to it here. So, for
example, maybe I'm going to tell it um I
want you to create a motion design of a
terminal typing out the following.
And then what I'm going to do is paste
this sort of system that I have here in
the terminal or here like basically what
the the sidebar of my coowwriter system
looks like. So, I give it like the
claw.md claude and then really just my
idea is to have a terminal. Type that
out. I'm going to tell it that and
you're going to see claude fire up. now
it's skill its remotion skill to create
this design and then we can see what
that looks like. So it's going to read
everything here all of its different
files. We're going to give it access to
all of that.
All right. And after Claude, you know,
analyzed everything here in its folder.
It's now updating its to-do and telling
us that it's going to create a terminal
typing animation that displays the
directory tree and it's going to create
a new composition file with the
realistic terminal. So, we're going to
let that run for another minute and see
what it comes up with. All right. Now,
you can see after it took about two or
three minutes, we let it run through
everything. It finished up its design.
And you can see it should automatically
spin up its uh server. And we can now
look at what this looks like. So, let's
go up. It it automatically pulled this
up. And now we have uh this this motion
design created just like that. So, we're
going to play it. You can see we told it
this is exactly what we wanted. I mean
this is insane. Like being able to
create this is um is pretty incredible.
So you can see it did everything
perfectly terminal corriter system and
it's going to loop here. All right. Now
we can even do some crazier stuff. So
I'm going to put this let's see I'm
going to put this side by side here with
our uh what we're working in here. And
what we can literally do is let's see.
So this is where we're working here. I'm
going to literally tell it to um let's
see start off the video with you know
the the text corowitriter system by Alex
McFarland and then uh flow into this
terminal and then at the end I want you
to put the URL of my landing page and
use my profile picture.
All right, I'm just going to tell
something like that just so I can show
you how you can now start expanding
this. So what I'm thinking is like at
the beginning of this I wanted to um you
know uh like just show that this is the
corowiter system
you know corowiter system by Alex
McFarland
and then what I'm going to do is
literally come over here and now on the
left you can see this folder here public
you can literally put images or videos
in here and then copy the path and put
it here and tell Claude to include those
in the designs. So, I'm going to grab a
profile picture of myself and put it in
there so we can put it into the design.
All right. So, we're going to come here
into the public folder. And I copied a
profile picture of myself. I'm going to
paste it in there. So, you can see now I
have this profile pick. All right. And
what we are going to do here is take
just the path of that, copy the path,
and give it to Claude. All right. I
don't know how good this is going to
come out. instructions weren't the best,
but you'll still be able to see the
point of expanding this out. You know,
creating multiple frames, putting in
your own images and assets. So, we gave
it to it. All right. It's going to say,
"What is the URL for your landing page?"
I forgot to give it that. So, it's
actually Alex McFarland.ai
system. Right. All right. So, we're
going to submit that. All right. So, it
got the URL. It got the photo of us.
And now, let's see what it can do. We're
going to let that run for another
minute. And then we'll see the update
here on the right. All right. So, Claude
just finished building that out. It took
like a minute or so, and it
automatically updates here in this
little studio here to the right. So, we
could see it added in here. It's telling
us it added in an intro, the terminal
scene, and then the outro, right? And
some extra files it created. And now we
can click this play button and see what
it looks like here. So now it has the
corriter system by Alex McFarland. We
have the terminal that we had already
before. This is so insane. I'm so blown
away by this. And uh that doesn't happen
too too often because most of the stuff
you see on X is like a ton of hype. But
now look at this. Now I'll put my image
here and it put the the um URL. So yeah,
like I was saying, most of the stuff you
see on X is like total hype and BS and
it's, you know, most of the time it's
not really good. But this was, you know,
one time where it's actually uh pretty
crazy. All right, so now we have that
built out. But like I said, um I also
created a Claude skill that will help
you create prompts. So let's try that
out now. So we're going to open up a new
instance of Claude here. And
uh what I actually did was copied the
skill already and we're going to paste
it here. So you can literally do this in
like this original folder like I created
that motion design folder all the way in
the beginning. You can literally do it
right here or you can put this in your,
you know, current claude system that
you're running or whatever. But here
we're going to go into doclaude. We have
the skills folder which has the remote
one. And now we are going to paste uh my
own motion design prompting skill here.
I put some references of example prompts
that I found were uh that I've been
using that were really good. And we have
this skill here. Let me make it a little
easier to read here.
All right. And then we have this motion
design prompt builder. So the purpose is
to guide users through creating detailed
motion design prompts that AI tools can
actually execute. All right, we give it
all sorts of reference materials in
different phases to follow. Right? So
now you can literally come to Claude and
be like, uh, Claude, I need your help
coming up with a motion design prompt.
Can you use your motion design uh prompt
skill?
And then the way I designed this skill
was to kind of give you two options.
Like if you already have an idea in your
head then you can provide that idea to
it or if you need help you can kind of
work with claude and it will kind of
help you come up with an idea right so
we say now I understand the format let
me guide you through creating your
motion design prompt I'll help you
create a detailed motion design prompt
that AI tools can execute do you already
have a concept in mind or do you need
help brainstorming ideas all right so
now just off the top of my head because
I haven't really thought about this but
let's try to give an idea we could say
like I have a rough idea of creating a
motion design that shows basically a
user um typing in a a query into a
terminal for example like creating a
LinkedIn post and then it's showing
agents being invoked um to uh you know
go create this content and that's kind
of my rough idea. Of course you're going
to have some ideas for whatever it is
you do but just to show you how the
skill will work here. So, it's going to
think and it's going to tell you um you
know what's this motion designed for a
landing page or hero animation product
demo and you're going to keep going
through because this is going to take
like 10 15 minutes you know however long
uh for you to kind of iterate with
Claude but in the end you'll be able to
come up with a prompt that looks just
like the ones I showed you earlier that
you can then just paste into this
whatever motion design studio to create
the these really cool designs. Now, the
last note I kind of want to want to say
is that the you know, I've been messing
with this for all day now and since last
night actually when it was released and
the one main thing I can say is don't
try to get super complicated with your
designs here because you know when you
try to get super complicated I was
realizing it was kind of getting really
messy. Things were not formatted
correctly. Pieces were all over the
place. Uh it was just not good. So it's
not at the point where you can create
like these super highlevel, you know,
intense motion designs. Uh you should
really try to keep it simple. So for
example, terminals like this work really
good. Text on the screen, putting links
and visuals like this work uh really
well. So that's the main thing I would I
would say to focus on right now. And
then the last point I really wanted to
leave you with was like, you know, most
of my work and all my videos and
content, you know, is all focused around
coowriter system, right? It's like
writing with AI, creating professional
non-development, like writing workflows
with cloud code or AI. Um, so when you
see me doing motion design, you might
not think that that, you know, is is on
par with the with the stuff I'm doing.
But, you know, something that's so
important going into the future now in
2026 is that, you know, whether you are
somebody who's trying to use these these
systems to make money, you know, for
example, you're trying to ghost ride or
or get marketing work for companies. or
if you're like a startup founder, you
know, and you're strapped for resources
and trying to carry out marketing by
yourself, you know, all of these just
add on to your stack of skills that you
have. So, you know, it's not just about
writing. Writing is the focus, but then
you can build on top of that. You know,
now we have like, you know, we already
have like research that can go on top of
that. We have image generation, video
generation, now we have motion design,
we have sound. So, when you add all of
that together, it not only just
supercharges your writing, but it just
makes you more of an AI operator who's
able to do all these different things
and it makes you so much more valuable
for either, you know, clients that might
want to hire you on to do work or for
your own company if you're like a
founder or something like that. So, if
you think about it, you know, if you're
trying to land, you know, a new client
and and it's you who only knows how to
use AI for writing versus somebody else
who knows how to use it for writing, but
also all these other marketing use cases
like motion design and video and
thumbnails and stuff like that, they're
going to choose that other person every
other time. So, this is all stuff you
should be learning. You know, I talk
about it all the time. I run several
digital content businesses, uh,
successful businesses all by myself. And
besides that, I ghost for CEOs. I've ran
content operations for startups. Uh I
have, you know, news publications that I
write for and I do all of this by myself
and it includes not just writing but
thumbnail generation, video generation,
marketing material, PDFs, now motion
design and I've never spent a penny on
outside help and I run all of this
myself. So, you know, take that, you
know, and definitely live by that and
start out by using this this motion
design skill. I'm going to include all
the resources below. Consider joining my
Substack where the Claude skill will be
if you need help prompting. And uh yeah,
drop any comments if you've tried this
out already.
