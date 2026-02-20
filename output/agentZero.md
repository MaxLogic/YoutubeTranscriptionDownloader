---
url: https://www.youtube.com/watch?v=SEBWHaX2L5s
title: This 100% private AI Agent can do anything… just watch
channel: David Ondrej
created: 2026-01-11
uploader: David Ondrej
view_count: 136231
like_count: 5479
comment_count: 468
tags: David Ondrej, david ondrej, AI, ChatGPT, artificial intelligence, ai, Artificial Intelligence, OpenAI, chatgpt, chat gpt, Chat GPT, AGI, midjourney, david ondrej podcast, GPT, new society, david ondrej new society, david ondrej community, make money with AI, AI Agents, ai agent, AI Agent Startup, AI SaaS, AI Startup
description: Learn about the best AI Business models here - https://www.youtube.com/watch?v=Ta5g-OxjPO4

Wanna scale your AI business? Go here: https://www.scalesoftware.ai/start

Docker image - “agent0ai/agent-zero”

Wanna learn how to code with AI? Go here: https://www.skool.com/new-society

Follow me on Instagram - https://www.instagram.com/davidondrej1/
Follow me on Twitter - https://x.com/DavidOndrej1

Host your n8n agents on Hostinger: https://www.hostinger.com/david

Subscribe if you're serious about AI.

Timestamps:
00:00:00 - Introduction
00:00:28 - Installing AgentZero
00:02:21 - Setting up Chat Model Provider
00:03:06 - Setting up API Key
00:04:14 - File Manipulation Use Case
00:06:11 - PDF Splitting Use Case
00:12:12 - Accounting Use Case
00:15:34 - Visual Data Analysis Use Case
00:17:31 - Image Manipulation Use Case
00:18:33 - Private AI Consultant Use Case
00:23:48 - Coding Use Case
00:28:05 - Personal Task Manager Use Case


www.vectal.ai
---

In this video, I'll show you eight
insane use cases for Agent Zero.
AgentZero is an open- source AI agent
with full access to the Linux terminal,
which means it can do literally
anything. The eight use cases I'm about
to show you save me hours every single
week, both in my business and in my
personal life. Agent Zero can do
accounting, coding, video editing, file
manipulation, and even hacking. But I do
have to warn you though, Agent Zero is
very powerful. It'll do whatever you
tell it to do. So, make sure to use it
ethically. Now, in order to use Agent
Zero, we need Docker. And the easiest
way to use Docker is to install Docker
Desktop. So, go to Google, type in
Docker Desktop, click on the first link,
and then click download Docker Desktop
and select your operating system. Once
you install Docker Desktop, it should
look something like this. Just make sure
to select the personal plan, which is
completely free. Now, the next step is
crucial, so pay attention. When you have
Docker Desktop open, go to the search
bar at the top and put in this exact
string. I'm going to put it below the
video, so you can just copy it. But this
is the official Agent Zero Docker image.
Just make sure you have the latest
version selected and then click on pull.
Then if you go onto the left inside of
Docker Desktop and click on images, you
should see the Agent Zero image right
here. Now the reason why Agent Zero is
over 5 GB is that it includes a full
operating system and a lot of software
pre-installed. This is what makes Agent
Zero so powerful. It can literally do
anything you can do in Linux. But it's
safe because it runs inside of a Docker
container. And because of the Docker
container, Agent Zero cannot mess up
anything on your computer. It's an
isolated environment. Now once the image
finishes downloading, click on the run
button right here, run. Then we go into
the optional settings. So this wants to
run a new Docker container. So click on
optional settings. Now the only thing
you need to do here in optional settings
is to put the number zero into the 80
TCP port. That's it. We don't need to
change anything else. Just make sure you
put zero in the port 80 and then click
on run. This will start agent zero in a
new Docker container and will give us a
link to use it on local host. So agent
zero runs completely locally. It isn't
sending data anywhere. Everything you do
inside of Agent Zero stays on your
machine. So, it's completely secure,
completely private, and the code is
fully open source on GitHub. So, if you
want, you can go ahead and inspect it.
And there we go. Agent Zero is finished
loading. Now, it gives you some links.
But this is the link we need to click.
Local host 55,000. This is the port that
was assigned. And if you click on it,
here you go. Now, there are a lot of
things agent zero can do, but first,
let's click on new chat. And let's try
sending new message, which should result
in an error. There we go. That's because
we haven't set up the API key. So, let's
go to the settings. So if you go to the
left, click on agent settings, agent
config. Scroll down a bit into the chat
model. Here we can select chat model
provider. And as you can see, you can
select open router, open AI, mistrol, lm
studio, hugging face, grock, deepsee,
basically any provider out there. You
can even select Olama and run your own
models locally on your machine. That way
no data ever leaves your device. But if
you want to use the most powerful
models, then you can use something like
open router, which offers every single
model out there, which is what I'm going
to show you now. How to use open router.
That way we can use the latest and
greatest models inside of agent zero.
Now to set up open router just go to
open router.ai and then we need to
select the model. So by default it's
GP4.1 but there are better models out
there namely cloth opus 4.5. I think
right now this is the best model in the
world. So let's copy this name. Go back
to agent zero and replace it here. Boom.
Let's click on save. But there is one
more thing we have to do. We have to set
the API key. So again let's go to
settings on the left here. We need to go
to external services. So select external
services at the top. Click on API keys
and scroll down until we find open
router. There we go. Open router. So
here we need to place the open router
API key. So let's go back to open
router. Go to top right. Make sure you
create an account. Takes like 30
seconds. Super easy. So go to top right
and click on keys. This will bring you
to your API key section. If you don't
have anything here, don't worry. Just
click on create API key. I'm going to
name it agent zero testing. Give it some
limit like 20 bucks. That way if your
API key gets leaked, you will not lose
more than the limit. Now again do not
share your API keys with anybody. Treat
them as passwords. I'm going to revoke
this key before uploading this video. So
click on copy go back to agent zero and
again make sure in opener here paste it
in and save. Now if we go to top left
and create a new chat and type in hey we
should no longer get this error and we
should actually get a response from
agent zero. There we go. Agent zero is
responding. Beautiful. So now we're
using Cloud Opus 4.5, the best model in
the world with Agent Zero that runs
completely locally, allowing us to
explore some insane use cases, which is
exactly what I'm going to show you right
now. The first use case I'm going to
show you is file manipulation. So Agent
Zero can transform different file
formats or work with hundreds of files
at once. It's actually pretty
impressive. So I'm going to have a PSD
file here, which is from Photoshop, and
I'm going to ask it to extract all
layers as PNG files. Now, normally you
would have to open Photoshop, save each
of these separately. it would be like a
5 to 10 minute process, right? With
agent zero, it's just a single prompt.
So, I just uploaded it here. And now
what it does is it uses the code
execution tool to run some Linux
commands. And again, you don't even know
have to know these libraries. The agent
knows what to do. It has full access to
Linux, but the Linux runs in the Docker
container. So, it cannot harm your
computer. This is the key difference
between agent zero, Codex, and CL code.
These agents run on your computer, so
they can delete your files. They can
mess stuff up. Agent zero runs in a
docker where it can do anything which
gives it its own operating system but it
cannot mess up your computer. And just
like that in a matter of 20 seconds we
have four different layers. So if you
look at the original file this is what
it looks like. It's a thumbnail for one
of my other videos. And again this is a
PSD file. So this is from Photoshop. And
these layers should be separate. So let
me save these. Boom. So it should be
just the background. Open that up. There
we go. Just the white background. Let's
look at the second one. Okay. So here we
have a slight issue. You can see there
are spaces in the name because that's my
bad. That's how I name it in Photoshop.
So, I'm going to say make sure to remove
the spaces from the layer names. Boom.
Uses a tool. And again, Agent Zero has
unlimited tools. So, unlike other AI
agents where you have to build new tools
for them, Agent Zero has access to every
single Linux library ever created.
There's like millions of those, right?
So, let's look at another layer here.
There we go. Let's open this up. There
we go. Here we have the text. So, this
is the text from the thumbnail isolated.
Let's look at the rectangle. Let's save
that. You have the rectangle. You know,
you can see the background behind the
text. And now this file. Boom. Here's
the NA10 agent node which we use right
here. So, literally something that would
take you at least 10 minutes to do
manually. Agent Zero did it in two
prompts in like a matter of 40 seconds.
And this is just the beginning. The use
cases later in the video get way more
impressive. Now, let me show you another
use case where agent zero performs way
better than close code. In fact, close
code failed to do this task which I'm
going to show you right now. So, I have
a PDF file. This is my personal bank
statement from December. The issue is
that when I tried uploading this into
one accounting software, it was more
than 20 pages. It's 24 pages. So I tried
giving it to cloth code which completely
failed splitting it in two halves. But
Agent Zero did it on the first try. So
let me show you. I'm just going to drag
the file into agent zero and say split
this into two separate PDF files
perfectly in half. Okay. Boom. I'm going
to send this off. Then I'm going to open
the terminal. I'm going to type in cloth
to start cloth code. All right. It's
asking me if I want to improve. I'm not
going to be sending more data into
Entropic. I'm going to say in this
folder, find the PDF file. And then I'm
going to say the exact same prompt.
Boom. Split this into two separate PDF
files perfectly in half. Enter. Now,
agent zero is already done because it
started first. But let's see if Cloud
Cool can do it because when I tried this
two days ago, it completely failed.
Okay, so it found the file. Good. It's
going to try to split it with PDF. It's
a Python library. It's asking me for
permission, which that's another issue.
Agent Zero doesn't need to do that
because it has full access to its own
operating system. It doesn't need to ask
me for permission. But code does. So
let's give close permission. Okay. Boom.
Error. All right. Let's see if it fixes
it. Okay. It first wants to install PI
PDF. All right. It needs another
permission. Enter. Another error. Agent
zero is already done. You know, agent
zero did it on the first try. No issues.
All right. Let's see if cloud code.
We're going to give it one more shot.
Let me try a different approach. All
right. So, it writes literally custom
Python command user flag blah blah blah.
Let's proceed. and it wants another
permission. Now, notice how much time
I've already spent here. You know, in
Cloudco, we have to give it permission
every single time because it's running
some risky commands. Okay, so it seems
like it managed to do it this time. It
only ran into like two errors and needed
three different permissions and it only
took like five times longer than agent
zero, but it managed to do it in these
two parts. But agent zero is already
done. So, if we click on these halves,
we can save them into the same folder.
Boom. There it is. Let me open this up.
We might need to blur all of this
because this is my actual bank account.
But yeah, so this is going to be
blurred, but you can see that it's 12
pages at the top. Right here, you can
see this 12 pages. There's the original
file. You can see that it's 24 pages
right here at the top. You can see 24.
So even a simple task like this would
take me a lot of time because I don't
know how to split in PDF. You know, I
could probably figure it out in half an
hour. But agent zero can do it in 20
seconds. While cloth code needed
multiple permissions, ran into two
different errors, and last time I tried
it, it failed. So here you can see the
power of Agent Zero having the full
operating system and access to all of
the Linux commands that exist. Now the
second type of use cases that Agent Zero
can do revolve around hacking or
penetration testing. So again, I'm not
your lawyer. Do not do what I'm showing.
It's all for educational purposes. Okay?
Make sure to be ethical and be good. So
here I have a password protected zip
folder. Okay? And let's say I don't know
the password to this, but I really want
to get inside of the zip folder. Well,
guess what? I'm going to put it into
agent zero and I'm going to say crack
this password protected zip folder. I
forgot the password so I need you to
brute force it. Boom. And agent zero
will do its thing and hopefully help us
open this zip folder. So again it's
installs Kali Linux I think runs some
packages some cracking tools. I don't
know if you guys are in cyber security
or if you're hackers you probably know
what it's doing. I have no clue. But
since I'm using Agent Zero, I can just
uh let it cook, let it do its thing, and
see how long it takes to crack this
password. It's trying different things.
It's doing John the Ripper. It's doing
dictionary attack. It's doing brute
force with common password patterns.
It's literally approaching this like a
senior cyber security professional
would. It knows what order of actions to
take. It knows what to do to crack this
in as short amount of time as possible.
All right, so it took a few minutes, but
here we are. It says the zip folder is
cracked. Here's the password. Summer 24.
So, it's not like one, two, three
letters. This is like what? 10 letters.
Like, some of you guys have passwords
weaker than this. Okay? It's not like 30
characters, but it's a standard
password. So, it it took a few minutes.
Obviously, the longer the password, the
longer it would take, but as you can
see, there are some files inside of this
folder. So, let's look at them. Save
this. Boom. I think this should just be
images of me. There we go. That's me.
And that should be another image of me.
Nice. So it successfully cracked the
password of this zip zip protected
folder which you couldn't do manually. I
mean it would take you years if you're a
good programmer. You could write Python
scripts. You know again you would have
to know what to do. You wouldn't know
the order of steps. But Agent Zero knew
exactly how to crack this in the
shortest amount of time possible. But
again we're only scratching the surface
here. So let me show you another use
case related to hacking which is finding
subdomains of websites. Right? So
companies often have domain website but
then they have like admin.eite.com
or dev.e. website.com which almost
always have weaker security. So if you
want to hack some website, again this is
not advice. I'm just speculating.
Finding these subdomains can be very
useful. So I'm going to send this find
all subdomains of scanme.nmap.org
which is built for this. So this is
completely legal and tell me which ones
are live. Show me the results in the
table. And we're going to let agent zero
do its thing. So it calls a subordinate
agent, gives a profile hacker, creates
the prompt for that agent. You're a
cyber security specialist performing
authorized reconnaissance on
scan.nmap.org.
Then the first agent, as you can see,
A1. So this is where the name comes
from, right? Agent zero is the first one
which delegates to A1, which stands for
agent one. It does its thing and this is
a specialized agent for cyber security.
And this agent is trying a bunch of
different things. Starting subway
enumeration, checking available tools,
installing Subfinder. So, it's install
some libraries or packages. Running
subfinder, trying alternative
enumeration methods, DNS brute force,
and MS. Again, have no clue what these
are. I'm not a cyber security
professional, but Agent Zero can do this
no problem. So, there we go. It found
four different subdomains. Uh, it took a
couple of minutes, but yeah, again, I
would have no idea how to do this, and
agent zero did it in a single prompt.
So, I think you're starting to see the
true power of this AI agent. Now, the
third use case I'm going to show you is
how to use AgentZero as your personal
accountant. Now, really, you can
delegate to it all of your accounting,
invoice processing, adding up expenses,
whatever you need to do, and Agent Zero
will do it. So, let me show you. I have
these three invoices right here. I'm
going to just upload them to Agent Zero,
and I'm going to tell it, calculate the
total USD value of these invoices. Let's
send that. And by the way, this could
easily be 30 or even 300 different
invoices. Agent Zero is excellent at
processing large files and also large
number of files. So, it uses the
document query tool with some queries
right here. Boom. Code execution tool.
Installs the necessary library to parse
these PDFs. And here's the response.
I've analyzed all three invoices from
Deonj. Boom. Google, Apple, Japka. So,
as you can see, these companies have
paid me 400K. Obviously, these are fake
numbers. Again, try it with your own
accounting. You'll be shocked. And
again, all of the data is local. So,
it's not being sent anywhere. It's not
being given to some third party
companies especially if you run a local
model like through Olama or LM Studio.
Everything stays on your machine. This
cannot be set for cloud code. This
cannot be set for CIGBT. Agent zero is
privacy first and it's security first
and it's always going to remain that
way. Now let's give it a lot harder
task. Again, this is my statement from
December. 24 pages of pure like hundreds
of transactions, right? So, I'm going to
say output a visual graph that
categorizes my expenses from December as
if you were a professional accountant.
Now, again, some of this might need to
be blurred because this is my actual
bank account statement, but I just want
to see how good Agent Zero really is at
accounting.
And by the way, you can expand any of
the agent zero bubbles and you can see
the thoughts, the inner workings of how
it works. You can see I've received the
data. This is a 24page document of
transactions. Again, some of this might
need to be blurred, but uh yeah, I just
want to show you the real power of Agent
Zero and uh that you can delegate to it
many of the tasks that you're still
doing manually or people on your team
are doing manually. Agent Zero is much
more powerful than people realize. So,
it's only a matter of time before
millions of people are using it. So, if
you're watching this, consider yourself
one of the OG people because Agent Zero
is still very underground. Even though
it already has 30,000 stars on GitHub,
most people still don't realize just how
many fix it can do and how many use
cases there actually are. So, boom. Now,
it's going through every single
transaction. Again, I'm going to have to
blur this, but watching Agent Zero work
is very, very impressive. And again,
keep in mind, I sent a single prompt.
So, you could go to a cafe, you could go
to the gym, you could do some push-ups,
whatever you want to do while Agent Zero
works by itself. And if you want to, you
can obviously launch multiple agent
zeros in parallel working on different
tasks. So boom, here is the first graph
that it generated. Again, we're going to
have to blur some of these amounts.
Probably just black them out. But look
at this beautiful pie chart breaking
down my expense distribution for the
month of December. And here's the second
report that I generated. Again, it's
going to be probably heavily blurred and
heavily censored, but man, this is
impressive. Different categories, all
the operational expenses beautifully
colorcoded into different expense
categories. And again, this would take
me manually hours like five to 10 hours
to do and a professional accountant
would probably charge you hundreds if
not thousands of dollars. Agent Zero did
it for couple bucks. I mean listen, you
can literally use super cheap models
that can do it for couple pennies and it
did it in what two three minutes guys we
really are living in the future. The
fourth use case I want to show you is
how good agent zero is at visual stuff.
So graphs, charts or manipulation of
images and photos. So I'm going to send
this prompt. Find the stock price of
Tesla, Microsoft, Amazon, and the price
of Bitcoin from the first workday of
each month in 2025. Then create a chart
showing comparison of their market cap
on those days in a single line chart.
Again, doing this manually would be
hours. I mean, so so much time, right?
And even if you hired somebody even
abroad from like Philippines or
whatever, still that person would take,
you know, day, two days, three days to
do it. And you would have to pay that
person way more than the price of these
few tokens. In fact, while it's running,
we can go to open router. And keep in
mind guys, we're using one of the most
expensive models. Cloud Opus 4.5 is
literally not a cheap model. This is one
of the most expensive models out there.
You could be using like Gemini free
flash, which is like super cheap and
still very powerful. But let's see how
many we spent on this API key. So far,
all of these use cases were just $4.7.
Okay, work that either would take me 20
plus hours or that if I wanted somebody
else to do it would be thousands of
dollars. Using the most expensive model,
it's $4.7, guys. Insane. if you actually
sit down and set these agents up, the
leverage is amazing. Now, most people
are just going to watch. They're not
going to put in the few minutes to
install Agent Zero and to use it. But if
you are going to do that, man, you're
going to have such an advantage over
everybody else. It's not even funny. In
2026, it's really going to be people who
are using the cutting edge AI agents
versus people who are just watching and
observing. A lot of people think that if
they're using CHBT, they're using AI,
but you're not even scratching the
surface. Tools like AI agents exist, and
most people are completely oblivious.
And there we go. The answer is here.
Look at this. We have the detailed
prices on the first work month of every
month. And do we have also the file?
There we go. Chart saved. So, let's
click on this. Let's save it here. There
we go. Let's look at the visualization.
And there we go. Market cap comparison
Tesla, Microsoft, Amazon, and Bitcoin in
2025 based on real web data created in
like one and a half minutes. Yeah,
incredible. Now, as I said, H&Z is very
good at working with images, visual
stuff. So, I'm going to give it this
photo of Moz. This is just sparkling
water. And I'm going to say remove the
background, add shadow, and resize to
1,00x 10,000. So, this photo is like
definitely not 1,000 by 10,000. This is
like a vertical photo. So, let's see if
Agent Zero can do this. All right, there
it is. Look at Look at that. It's crazy,
guys. This is insane. So, the background
was removed. The wooden floor is gone.
There's a drop shadow you can see around
it. And it's resized to 1,000 x 10,000,
guys. Literally, you would have to do
this in Photoshop or some, you know,
Canva, whatever, some image editing
tool. You would have to first have these
subscribed. Like Adobe subscription is
not cheap, right? And then you need to
have the skill set to remove it. Even if
that, even if you have the subscription,
even if you have the skill set, it would
take you a couple minutes to do. What
did I do? I simply dragged the file into
agent zero and did like six, seven words
and boom, it ran for like minute, two
minutes. And here we go. We have the
file exactly as I wanted. Crazy. I don't
know what to say. Now, the fifth use
case how you can use Agent Zero is as
your private AI consultant, right? CHGPT
is not private. They collect all your
data. They use it to train different
models and they sell it to advertisers
because ChBT now has ads. Same with
Plexity. Same with all these cloud-based
solutions. Agent Zero is local. It runs
locally on your computer. So, the data
stays here. So, for example, I have
these files which are from Tesla. But
let's say this is your company files,
right? Or this is like your personal,
you know, transcript from a therapy
session or some, you know, data about
your health, maybe blood test results,
whatever you want to keep private,
right? There's a lot of things you don't
want to share on the internet. You don't
want others to know, you don't want the
government to know, whatever. So, let's
say this is like your business data,
right? You run a business. This is
internal documents that you want to chat
with and you still want to use an AI
model to analyze them and to go back and
forth but you don't want to give this
data to open AI or enforopic because who
would trust these companies right this
is [snorts] like the dumbest idea you
can do so in Asian zero everything is on
your computer so you can actually do
this based on these two files help me
understand
how we can scale the business further
and again these are SEC filings from
Tesla so obviously it's not my business
it's Elon business. But you get the
point. These could be your CSV files.
This could be Excel files, docu uh
Microsoft Word files, whatever files you
have, Agent Zero can process them, and
it can help you chat with them without
anything leaving your machine. And
again, if you want to take this to the
extreme, go to settings, go to agent
settings, switch the provider to Olama.
Boom. Ola right here. And you can run
agent zero with Olama. So if you have
some models already downloaded, let's
say like the Nemo short free nano, which
again is like a 30 billion model and
it's very powerful model, you can run
this if you have a decent computer,
right? You just need like 25 30 uh GB of
VRAM. And this model is probably better
than the original GPD4 was, but you can
easily run it locally on your machine.
And by the way, we're going to make a
full tutorial on how to use Agent Zero
with Olama, so that you can run local
models as well on the AgentZero channel,
which is going to be linked below as
well. And there we go. So, agent zero
analyzed the detailed SEC filings and
gave me a very strong answer based on
it. And again, doing this manually would
be ours. The sixth use case I'm going to
show you is video editing. So, Agent
Zero can do a lot of basic video editing
operations. Let me just show you. I'm
going to paste in this 4K footage, which
is uh almost 2 GB. I'm going to say
rerender this as a 1080p file. Boom.
Again, maybe you don't have Adobe
Premiere installed or, you know, Da
Vinci or whatever. Maybe you don't know
anything about video editing. Or maybe
you just don't have time. Maybe you're
working on some bigger project in Adobe
and just want to quickly rerender this.
So you throw it into agent zero. You
tell it a single prompt, go to the
toilet and few minutes later, you'll
have the 1080p rerendered file. So now
Asian zero is running ffmpeg to rerender
this. And again everything is local.
Everything is within the docker
container. All right, here we go. So it
took like 2 minutes because you know
rendering takes time. But here we have
the 1080p version of the file. And we
can even see I didn't even ask for this
comparison table, but it's very useful.
So original is 4K with 45 bit rate. It's
uh nearly 2 GB. This is compressed to
just 200 megabytes and it's 1080p. So we
can download this. Boom. Boom. Open this
up.
And yeah, it's still good quality. Very
nice. It's just 1080p. And we can even
double check it just to make sure that
Agent Zero isn't lying. So, this is a
1080p version. Let's do uh get info.
There we go. Dimensions 1920 1080p. And
if you look at the original, let's do
get info. You can see this is 4K
footage. Amazing. Now, let's take it a
step further. We're going to give it
another video editing task. I'm going to
say take this 1080p
file and rerender it as a 1,00%
time-lapse with no audio. So maybe you
have some, you know, skiing footage or
some flight footage or driving footage
and just want to time-lapse. And again,
you can absolutely do this in Adobe
Premiere, but it would take you a few
minutes and you have to do it manually.
Guys, it's 2026. Why are you still doing
these tasks manually? Things like Agent
Zero exist. Now, most of you probably
don't know about Agent Zero until now.
And most of you that do know about it
probably won't take the few minutes to
set it up. But those few percent of you
who are the exceptional individuals will
get such a crazy advantage if you
actually start using agent zero for
these small tasks. Save 2 minutes there,
5 minutes there, 30 minutes there. It
adds up. It compounds. If you use agent
zero for all 2026, man, you're going to
get work done of like three people. Now,
maybe some of you are entrepreneurs,
maybe you have three people on your
team. Think about the power if you
distribute agent zero to all of them and
if you instruct them to use agent zero.
This really compounds every single unit
of your time and it allows you to do
tasks that normally you would need
expensive software for or skill sets
that take months or years to master.
With Agent Zero, it's like a single
prompt. Couple minutes and it's done.
So, boom. Here's the time-lapse.
Time-lapse is ready. 10x speed. Let's
download it and let's watch it.
Yeah, you can clearly see this is a
time-lapse, man. A amazing. Now the next
insane use case for agent zero is
coding. A lot of AI agents can do coding
but usually they cannot actually run the
code. So look at my prompt. Write a
Fibonacci function three ways loop
recursion and memorization. Run each one
100,000 times and tell me which is
fastest with exact timing. Right? So not
only can it write the code for this, it
can also run the code time it and give
you the results of this benchmark. So
let's say you have a you know some
sorting mechanism in your app or you
have like two different implementations
of your back end and you want to see
which is fastest without deploying it to
production you just send it to agent
zero and it will run it it will write
the code run the code and then tell you
the results. So we can see the memorized
is the fastest 1x this is 75 times
slower and pure recursion is 14,000
times slower and this took like what 25
seconds. Incredible. Another use case
related to coding is going to be
compiling code into an executable. So
let's say you have some code you paste
it in there could be the raw text or
obviously file attachment and then you
say take this Python script install PI
installer and build it into standalone
executable. To be honest, you don't even
need to drop the name PI installer. It
would know what to do. But basically,
just say, give me an standalone
executable, then run the executable and
show me the output, right? So, you give
it some code and you let it cook. You
let it turn it into an actual app, an
executable that you can execute, you
know, you can run it. It's not just a
Python script that you would need.
Python installing machine, you would
need to use it in the terminal. No,
it'll just give you a executable package
and it can even run it itself and check
the results which again cloth code
cannot do and even if it could do it, it
would ask you for permissions every step
of the way and it would run into errors,
all that stuff. It would just be a lot
of user input if you wanted to use clo
or something else. With agent zero, you
don't need to do that because it has its
own operating system. So, it can just do
anything it needs to do. There we go. It
ran the command. It gives us the script.
We have the executable right here. We
have the build spec everything we need
and it even ran the executable and gave
us the result of the script. So current
temperature in proc minus 10 pretty
crazy I cannot wait to go back to Dubai.
The next coding related use case is
going to be debugging. So again I'm
going to give it some code boom this is
a Python script simple Python script but
this could be as complex as you want.
And then I'm going to say profile this
script with C profile. Show me the three
slowest functions and explain why
they're slow. So it's not just looking
at the code. It's real debugging. It's
going to do a speed profile of these
different functions and then analyze
what could be making these functions
slow. Boom. There it is. Z profile
analysis results. Total execution time
0.6 seconds for 10 iterations of main.
Pretty slow functions. So slow function.
Boom. Why each function is slow? So
obviously there's a fake sleep timer
because it's a simple script. But feel
free to test it with your code and
you'll be surprised what agent zero can
find. Now let's take it one step further
and let's see if agent zero can execute
a full analysis of a GitHub repo. How
secure it is and whether there are any
critical vulnerabilities. So a lot of
you are vibe coders, right? You're not
professional developers. So you're going
to have security vulnerabilities. You're
going to have issues with your code,
bugs, gaps, improper authentication, all
that stuff, right? So you can just give
it your GitHub repo or just upload all
the files individually and have Agent
Zero test your project. See if it can
find any gaps before it goes into
production and before you run into any
serious issues. Now again this is taking
a few minutes because it's loading a
whole repo and uh setting up the NexJS
environment or node server for this. But
you get the point. Agent zero can do a
lot when it comes to coding but in a
different way than cloud core cursor
because it can run its own server. It
can execute the code. It can analyze it.
It can install libraries to pentest the
code. All these things plot code or
cursor either cannot do or you would
need to give them the tools. You need to
build the tools or you need to connect
MCP servers that already exist. But you
need to know these servers exist, right?
So there's a lot of knowledge or a lot
of skill required to properly use these
other tools. Not with agent zero. With
agent zero, you type in plain English
and it will figure out what to do by
itself. It will test it. If it runs into
error or try something else, it doesn't
ask you every two seconds for
confirmation. because it has its own
operating system inside of the Docker
container. Now, the eighth use case I'm
going to show you for Agent Zero is
using it as your own personal task
manager where all of the data stays on
your machine. So, as the world
governments are becoming more and more
authoritarian, as companies collect more
and more data, it'll become more and
more essential to keep as much as your
data private local in your machine, not
uploaded in the cloud, not reliant or
Google or you know big tech including
task manager. So let's say you don't
want to use notion or to-doist or
whatever. You want to keep everything
locally in your machine. You can do that
with agent zero. So I told it you are my
personal task manager. Store everything
in tasks MD. Track task name, due date
and priority. When I add tasks, save
them. When I ask what to focus on, tell
me what's overdue or due soon. Sorted by
priority. So again, this is not just a
private list, a private database of
tasks. Since we have a full AI agent
here, it can think, it can reason and
tell you what to focus on. So for
example, you can tell it add a task
finish YouTube script high priority due
tomorrow. And it will hopefully update
the local file which is stored in the
Docker container by inserting the task
into the task list.
There we go. Here's what our task list
looks like right now. Let's add another
task. Review vectoral PRs medium
priority due Friday. So boom. Now we
should have two tasks in our task list.
There we go. Let's add a third one. So
the third task is book dentist
appointment low priority due next week.
There we go. Everything is stored inside
of this tasks MD file. And now here
comes the magic, right? You can say what
should I focus on today. Obviously with
three tasks it's easy. But let's say you
have 20, 50 or 100. Personally I have
hundreds of tasks in my task managers. I
literally spent the last 14 months just
solving this problem myself with vector,
right? Because my mind is a storm. It
constantly generates new tasks. I get
between 10 and 40 new ideas per day that
I have to write down. And task pization
is, you know, a huge huge problem for
people who run businesses and who do a
lot of things. So agent zero lets you
manage your tasks completely locally.
Everything is private. Everything is
secure. Nothing leaves your machine.
It's stored in a markdown file or you
can do different formats like CSV file,
whatever. Doesn't really matter. The
main thing is that it's privacy first,
right? Your tasks and your data isn't
leaving your machine. It's in here and
you can still use powerful AI models to
interact with it and to help you sort it
out. So let's say today's focus finish
YouTube script. This is your number one
priority. We have less than 24 hours to
complete it. Amazing. So I have
intelligence in my task list and the
data is private. So yeah, this really is
the future. local software that is
custom private on your machine and Agent
Zero is a huge step towards that. Now,
if you want to learn more about Agent
Zero, go to the Agent Zero GitHub, give
it a star, and play around with it
yourself. At the beginning, I showed you
how to set it up. So, go back and watch
this video again. As I said, there's a
huge difference between people who are
simply watchers and people who are
doers. If you watch and you don't
execute anything, you don't implement,
you're going to get no value. You'll get
still some dopamine. You feel like
you've learned something. you feel like
you're on the cutting edge of AI, but if
you actually are serious about AI, go
and watch this video again and implement
every single step. Try these use cases
on your own files. Try all of them and
see what works. Try stuff that I haven't
tried and comment below what works.
Agent Zero is super powerful. It can
literally do anything. So, people are
still discovering what it can do. And if
you're a developer and if you want to
build on top of Agent Zero, again, go to
the GitHub. I'm going to link it below
and give it a star and fork it yourself.
It's fully open source so you can go
through all the files and see how it
works. Yeah, this is the difference
between agent zero and cloud code and
cursor. These tools are not open source.
So you have no idea what's happening
inside of them, which data is being
collected for agent zero. You know,
nothing is being collected. Everything
is on GitHub. You can go through it and
look at it. That being said, these are
eight insane use cases on Agent Zero. So
yeah, if you like this video, make sure
to subscribe and also subscribe to Agent
Zero's channel. With that being said,
thank you guys for watching and I wish
you a wonderful productive week. See
you.
