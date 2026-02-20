---
url: https://www.youtube.com/watch?v=rk66k_tuZec
title: Claude Code's Ralph Wiggum Plugin Changes Everything
channel: Eric Tech
created: 2026-01-11
uploader: Eric Tech
view_count: 14799
like_count: 406
comment_count: 36
tags: Claude Code, Ralph Wiggum, Ralph Loop, Claude Code plugin, autonomous AI coding, AI agent tutorial, Claude Code tutorial, stop hooks, Anthropic Claude, AI software engineer, automated coding workflow, Ralph Wiggum setup, MCP, TestSprite, multi-agent AI, Eric Tech, autonomous dev loop, AI debugging, cursor composer alternative, ai, artificial intelligence, the simpsons, ralph wiggum, ai automation
description: Tired of Claude Code stopping halfway through a task? The Ralph Wiggum plugin creates autonomous feedback loops so Claude keeps iterating without manual prompting.

Checkout TestSprite here: https://www.testsprite.com/?via=eric-tech

In this tutorial, I show you how to install the Ralph Wiggum plugin and configure "stop hooks" that let Claude Code run continuously through code reviews, testing, and bug fixing—all on its own.

What you'll learn:
→ How to install and configure Ralph Wiggum for Claude Code
→ Setting up infinite loops with custom stop conditions
→ Multi-persona workflows (QA, PM, Business Analyst) for production-ready code
→ Real demo: Building a receipt scanning app with autonomous iteration

━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 RESOURCES & LINKS

💬 Get FULL prompt here: 
Join our Discord: https://discord.com/invite/erictech

📅 Work With Me
New Projects - Free Strategy Call: https://calendar.app.google/sB9KrJP6e8j3EPmd9
Technical Consultation (Paid 1:1): https://calendar.app.google/BU9D589X3KNxnTeg6

🤝 Let's Connect
LinkedIn: https://www.linkedin.com/in/ericwtech/

🔗 RELATED VIDEOS:
→ Claude Code Front-End Design Skills Tutorial: https://youtu.be/bFC1QGEQ2E8?si=rCPe7ut5XPrybwwM
→ Specify Github (Spec Driven Development): https://youtu.be/-9obEHJkQc8?si=rFhetAcG3XBZD5zn
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ Timestamps:
00:00 - Why Claude Code needs infinite loops
00:52 - Problem
01:11 - How it works?
02:52 - Installing Ralph Wiggum plugin
03:34 - Commands & loop configuration
04:33 - Real demo: Planning Phase 2 features
07:23 - Multi-persona loops (QA, PM, Analyst)
10:32 - Final results & app demo

#ClaudeCode #RalphWiggum #AIProgramming
---

Anthropic recently released the Ralph
Wigan plugin. And in this video, I'm
going to show you why we should use it,
how to set this up on your local
machine, and how we can be able to
introduce different team roles,
different personas, autonomously calling
different roles to improving your
applications iteration by iterations
until you have a production ready
applications. So, pretty much that's
what we're going to cover in this video.
And if you're interested, let's get into
it. All right, so before we jump in, a
quick intro for those who are new here.
My name is Eric. I have spent years as a
senior software engineer at companies
like Amazon, AWS, and Microsoft. And I
have started this YouTube channel to
share everything I have learned along
the way from AI and coding to
automations, web 3, career developments,
and more. All broken down into practical
tutorials that you can actually follow.
So, if you're ready to level up, make
sure to check out my YouTube channel and
hit that subscribe button. Now, let's
get back to the video. Now, what is the
problem that this plug-in really trying
to solve? Well, in traditionally when we
try to use claude, we provide the
prompts and when cla think that it
finished the job, then it will stop,
right? But the thing is that there's so
many things that we're going to improve
after it's done. Maybe the user
experience or running a bunch of
testings or maybe try to review the
system overall and it takes a lot of
iterations over iterations to achieve
the best solutions. And that's why ruff
wum here is going to solve this problem.
And the way how it works behind the
scene is that once we provide the
prompt, claw code here is going to
perform your instructions and then once
it finish it will basically trigger a
claw code hook that whenever it stops
then it will basically pass the prompt
back to claude and try iterating through
until it finish all the loops. And all
we had to do here just provide how many
iterations that claw code have to
perform and also a condition on when it
should break which I'll show you later
on how you can be able to craft a
perfect prompt like this. So pretty much
that's how it works behind the scene and
why we should use it. Now you understand
everything. Let's take a look at how to
set it up on your local machine. How we
can use it autonomously to continuously
improving your applications overall and
make your application production ready.
But before we do so, I want to give a
quick shout out to the sponsor of this
video, Testbrite. Testbrite is an AI
agent built specifically for software
testing. And with the release of the
Testbrite MCP, you can now use it
directly inside your coding IDE. So,
cursor, windsurf, cloud code, and more.
Setup is super simple. You just add the
configuration in your MCP settings and
you're good to go. What I really like
about Testbrite is that it doesn't
blindly run tests. It first reads
through your entire codebase,
understands the documentation, and
validates the results your AI agents
produce. It automatically generates a
test plan from your PRD, creates test
cases, ensures proper test coverage, and
all of that without any manual input.
From there, it executes a test and sends
detailed reports back to you, clearly
showing what's broken and what needs
attention. Most coding agents today
average around 42% accuracy. But with
Testbrite MCP, teams have been able to
boost feature delivery accuracy up to
93%. So if you're interested in checking
it out, you can watch the video I made
on it or click the link in the
description below for more details. Back
to the video. All right, so to get
started, first thing first, we're going
to CD into our project. And once we're
in a project, we're just going to run
the claw code. And here you can see we
have our claw code session open. And
what we're going to do first is try to
install our marketplace inside of a claw
code. So if I were to run this, you can
see it's going to add a marketplace into
our plugins. And once we have this
installed, what we can do now is to run
the next command, which is to install
the Ralph Wim into our Claw plugins. So
now if I were to run this, you can see
is because we already have this
installed. So all I had to do here is
that I'm just going to use the /plugins
to basically see if our Ralph Wiggum
here is installed. So if I were to run
the /plugin and if I were to do the
installed, you can see that we have our
Ralph Wiggum here successfully installed
inside of our Clark plugins. All right.
So now once we have this confirmed then
next step is to take a look at how to
use it inside of our clock session. All
right. So now to use it is very simple.
Here you can see that if I were to type
in the /walwig here you can see that we
have three options we can choose. So one
is we can cancel the current Ralph
wiggam loop. Basically if it's currently
running we can be able to use the slash
command here to cancel it. And the other
one is basically type in help to
basically try to see if there's any way
that we can be able to add additional
options to it. Things like that. And the
last one here you can see this is where
we're going to have the walum here to
start the loop. So if I were to do tap
here and here you can see that we have
three options that we can pass into this
slash command. One is the current prompt
exactly what we want the clock here to
do and then it also mentions how many
max iterations it should be able to
perform and then after loop is completed
what kind of things we want to display
inside of our clock session. So after
this is completed, we can be able to put
replace like done. We can be able to put
a check mark on it, things like that,
right? So pretty much that's how we can
use Rob Wickum inside of a clock
session. So in this case, let's try to
put it into practice and see how we can
use it to basically complete a projects
based on this. All right. So to show you
a demonstration here, you can see I'm
currently in my clock session. And if I
were to scroll all the way down, you can
see that I have claw code here, generate
a task list. Now, just a little
background about this project.
Currently, I have the phase one of this
project completed. And currently we're
trying to moving on to phase two. So
there are some unstage changes that we
have inside of a current branch. So we
want to first have clock here to commit
them. And the most important part here
is that we're going to have clock here
create a spec driven development
planning. Basically try to do the spec
plan and spec tasks. Basically generate
a list of task before we do the
execution. So right here you can see
it's going to show you how exactly going
to commit those changes. Right? Breaking
the local unstage changes into multiple
commits. So then after that here you can
see that we have our phase 2 for the
spec kit planning workflow. So we're
going to have clock here to generate the
entire plan. So for these features right
here you can see we have our spec but we
don't have our plan or tasks. And for
these additional features we don't have
a spec for these features at all. So
we're going to have clock over here to
generate the spec the plans the entire
task list for all the feature we're
going to complete for phase 2. And if we
were to take a look at this expected
output here you can see that these are
all the features that we have. So for
all those features you can see for each
features we have roughly around 120 or
150 to 200 task uh generated in total
you can see that we have roughly around
900 to 1,100 task that we're going to
have claw code here to do and we're
going to put them into a master task
list which will aggregate them into one
single file. So in this case I'm just
going to execute this and let clock here
to generate the task list first before
we move on to next stage. So now you can
see we have clock here generate the spec
the plan and also the task list for the
entire features for phase 2 and here you
can see all we had to do here just run
this command here and basically I can
just pass this to ruffle gum here to
basically run this autonomously. So in
this case, let's take a look at how to
do that. And just for your reference, I
also asked Claude because I was thinking
if I can be able to run this entire,400
task autonomously using Ralph Fugum. But
here you can see Claw recommends that we
want to do this feature by feature
because it creates a separate branch.
Right? So in this case, what we're going
to do here is we're just going to check
out that branch using raffle gum hero to
basically do the implement and then
continuously do the testing review
repeating the phase two and phase three
until we have a perfect solution and
then we're going to merge that into the
main branch and then repeat that process
to the next feature instead of using
this rough here for the entire 1,500
task list. So in this case that's
exactly what we're going to do. I'm just
going to first check out to this one
first and run with Ralph Wum here to
basically in that single branch. All
right. So then what we're going to do
here is I'm just going to first check
out to this branch right here for the
first feature that we're going to
implement. So right here you can see
we're just going to use the Ralph Wiggum
command. And here you can see we're
going to pass the prompt right here and
then we specify the max iteration. So
here you can see I specify that we're
going to start with 20 iterations for
testing. But in terms of what we're
going to put for the prompts, this is
the most important part because a lot of
people they just think oh complete this
or run the spec implements. But keep in
mind that after this iteration is run,
it's going to run multiple iterations,
right? So we want to make sure that this
prompt is consistent in each iteration.
So that it's not like it's only used for
one iteration. We're going to use it for
multiple iteration. So here you can see
that this is the prompt that I prepared.
So first I specify where we're going to
complete this. In this case, it's going
to be in this branch right here for this
particular feature. And then I specify
we're first going to read through the
entire task list to see if there's any
tasks that are not completed. If they're
not completed, well then complete them
first and mark them as checked. Then for
the phase two, we're just going to
rotate into different personas, try to
review the entire codebase and try to
perfect it. And to in order to perfect
it, we have to introduce multiple
personas to review it. Because in a real
life situation, we have different people
on your teams try to review the code,
right? People who are your co-workers,
maybe they're also a developer. They're
trying to review your code. Maybe they
are a solution architecture. Try to make
sure that the file structure, the
dependencies also if there's refactors
needed. And then there could also be
like front end designers try to use
maybe like the front end design skill
from claw code which you can learn more
about the skill particularly in this
video right here. Okay. And you can use
that to basically perfect UI user
experience for this application like
improving the components the
accessibility the responsiveness right
and also maybe like QA also think about
like how can be able to increase the
test coverage aiming for like 90% above
and also writing the missing unit test
for the edge case that we can find.
Okay. There's also project managers, the
business analysts, try to switch over to
different personas here, try to improve
our applications in each iteration.
Okay. So here you can see that for each
iteration here identify the current
persona and try to perform that
persona's review and also make one
improvements or fix and also commit with
messages based on that persona and a
description and also if there's any
issue found by any personas for two full
cycles and then output it for completion
because if this issue continuously
happened then we definitely want to stop
it and basically have human get involved
into this so that we're not cycle
through in a dead end. Okay, so there
must be a condition when this thing have
to break. And I'm just going to come
back to the clock session, paste the
prompts, and we're just going to have
Ralph Wiggum here to basically loop
through each iteration. So in this case,
I'm just going to run this and let's see
what's going to happen. All right. So
right now, you can see it's still
iterating through. Let's take a look.
It's currently at the fifth iteration.
So it's going to choose the business
analyst. It's using the module here to
basically pick the uh person or the
persona it's going to take over here to
review. So it's going to review one by
one, one by one until we finally get to
you know everyone here to review it.
Right. So here you can see this is the
previous one which you can see this the
previous role I think for before QA is
project manager and this is the project
manager notes. So this is the project
manager and this is what has complete.
So you can see it gives some feedback
and then it start to do the fix right.
So right here you can see and it start
to do the business analyst here. So here
is what the findings from the business
analyst for the issues and then it's
trying to make the updates. Okay. And
then it's going to cycle through and try
to have different persona here to review
it. And right now it's going to move on
to the co-reviewer iteration. Okay. So
in this case, let's wait for a bit until
it fully completes. And then here you
can see the Ralph loop has completed
with two full cycles and cycle three
cycle four. The feature all pass with
six personas review without any issues.
All right. So in this case it should be
good. Now if I were to run mpm rundev
and try to run the application again.
All right. So now you can see I've
navigated back to the receipts page. And
right here you can see the features
added for import from cloud. So here I'm
just going to import receipts from cloud
storage like Google Drive, Dropbox, S3
share links and import those receipts
into our table. So right here I'm just
going to navigate to Google Drive and
I'm just going to copy that link and
paste it right here. So I'm going to
click on fetch. Here you can see it auto
detect Google Drive. And here you can
see we have found three files inside of
this Google Drive folder. So I'm just
going to click on import three files.
It's going to import all three files
into using our OCR system here to
extract those informations and output
them onto our uh tables. Right here you
can see we have our vendor, we have our
V uh payment method, right? We also have
our amount. We have our upload date
status. We can also click on the preview
to preview the actual receipt. You can
see that this is the receipt right here
which we also have our link from the
Google Drive folder and simply we can
open this and be able to use it. So
pretty much that's how we can be able to
use Ralph Wickham here to continuously
iterating through our cloud code session
and basically iterating and until we get
a perfect solutions at the end. Okay, so
pretty much that's how it works. And if
you do familiar this video, please make
sure to like this video, consider
subscribing for more content like this.
But with that being said, I'll see you
in the next video.
