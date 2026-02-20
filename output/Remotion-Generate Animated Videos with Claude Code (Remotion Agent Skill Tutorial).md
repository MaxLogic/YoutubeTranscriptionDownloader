---
url: https://www.youtube.com/watch?v=EwKCAgt4aKI
title: Generate Animated Videos with Claude Code (Remotion Agent Skill Tutorial)
channel: Snapper AI
created: 2026-01-22
uploader: Snapper AI
view_count: 4497
like_count: 80
comment_count: 4
tags: claude code, remotion
description: Create animated videos with Claude Code and the new Remotion Agent Skill.

Remotion is a React framework for creating videos programmatically, and with the new agent skill, Claude Code can now generate Remotion animations from simple text prompts.

In this tutorial, I take a static HTML infographic and turn it into a fully animated MP4 using just three prompts. No timeline editing, no keyframes, no React knowledge required.

Full workflow covered: project setup, installing the agent skill, prompting Claude Code, iterating in dev mode, and exporting the final video.

🎓 Skool community coming soon — exclusive content, direct access & Q&A. Founders lock in lowest pricing forever → https://snapperai.io/skool

⏱️ TIMESTAMPS

00:00 What This Video Covers
00:45 Final Animated Video Preview
01:34 Scaffold a Remotion Project
02:15 Install the Remotion Agent Skill
03:01 Project Structure & Asset Setup
03:37 Prompting Claude: Staggered Card Animation
04:18 Live Preview: Stagger Animation
04:55 Prompting Claude: Spotlight Effect
05:43 Live Preview: Spotlight Animation
06:30 Final Prompt: Expand Cards + Count-Up Numbers
07:13 Live Preview: Final Animation
07:46 Exporting the Video to MP4
08:14 Key Takeaways & When This Works Best

🧠 WHAT THIS VIDEO SHOWS

◆ How Claude Code can generate real Remotion animations from text using the Remotion Agent Skill
◆ How to iterate visually using Remotion’s dev mode
◆ Why agent-based workflows are powerful for video generation
◆ Where this approach shines (and where manual control still matters)

🧑‍💻 COMMANDS USED

# Scaffold a new Remotion project
npx create-video@latest 

# Install the Remotion Agent Skill
npx skills add remotion-dev/skills

# Export the final video to MP4
npx remotion render BenchmarkResults out/video.mp4

Claude Code is then used to:
◆ Modify animation timing
◆ Add spotlight effects
◆ Expand layouts
◆ Implement count-up animations

All animation logic is generated directly into the Remotion project.

🔗 REMOTION LINKS

Remotion website: https://www.remotion.dev/
Remotion GitHub: https://github.com/remotion-dev/remotion
Remotion Agent Skill: https://github.com/remotion-dev/skills
Remotion X announcement: https://x.com/Remotion/status/2013626968386765291

▶️ WATCH NEXT

→ How the Creator of Claude Code Sets Up His Workflow: https://www.youtube.com/watch?v=aqtseECSdtY 
→ Claude Code Advanced Workflow Tutorial (Slash Commands & Subagents): https://www.youtube.com/watch?v=6rdQXdEy-8U
→ AI Coding Benchmarks: Bug Fix, Refactor, Migration: https://www.youtube.com/watch?v=_dMm8sHmtCs
→ GLM 4.7 vs Opus 4.5 vs GPT-5.2: One-Shot Build Test: https://www.youtube.com/watch?v=XFuA1gRau4M  

🔔 SUBSCRIBE

Subscribe for AI coding workflows, agent tooling tutorials, and hands-on benchmarks.

🌐 Website & newsletter → https://snapperai.io
🐦 X / Twitter → https://x.com/SnapperAI
🧑‍💻 GitHub → https://github.com/snapper-ai
🎓 Join the Skool waitlist → https://snapperai.io/skool
---

Remotion just dropped an agent skill
that lets Claude code generate fully
animated MP4 videos from just a text
prompt. If you haven't come across
Remotion before, it's a framework for
creating videos programmatically using
React. Instead of dragging clips around
in a timeline, you write code and that
code renders into a real video file. The
trade-off has always been that you
needed to understand React and
Remotion's animation model to use it
effectively. This new agent skill
changes that you can now describe the
animation you want in Claude code.
Claude generates a proper Remotion
project using best practices and you get
an animated video out the other end. In
this video, I'll show you a real
example, then walk through the exact
workflow, how to set it up, how to
prompt it, how to iterate on animations,
and how to export the final video.
Here's a static infographic I've used in
a few shorts I've published. It's HTML
that I built with Claude. I explained
what I wanted, provided the data, and
Claude generated the infographic so that
I could capture it in the browser while
recording. What I'll show you now is the
final result after running this through
Claude code with the remotion agent
skill. If I hit play here, we can see
the once static infographic now has
these staggered animations and each card
isolates on screen so you can focus on
one at a time. For something like a
benchmark breakdown or a comparison
video, this makes the content much more
visually engaging without needing to
manually animate anything. And this is
just one workflow. The same approach
works for websites, data visualizations,
anything you want to animate. So with
that context, let's jump into the CLI,
install Remotion, and I'll walk you
through how to set up the project,
prompt Claude code, and test your
animations. So the first thing you need
is Node.js installed. If you've done any
web development, you probably already
have it. If not, head to no.js.org and
grab the LTS version. It's a
straightforward install. Then you want
to open up your terminal and use this
command, npx create video latest. This
is Remotion's project scaffolding
command. It'll ask you a few questions.
It'll ask you to choose a template as
well. It doesn't matter what we choose
here. We'll just choose Hello World. You
can then choose the directory where you
want to create this project scaffolding.
In this case, I'm using Remotion demo as
the project. We're going to say yes for
Tailwind CSS and we'll say no for VS
Code. So then we've created our project
scaffolding, which is the first step in
the process. Next, we now want to change
into our directory. So we want to move
to Remotion demo. Then we want to
install the agent skill. So to do that,
we need to type in npx skills add
reotiondev/skills.
Hit enter and that's going to install
the new agent skills for claude code.
You can see here you can also choose
codeex and cursor. For this video we're
going to use claude code. So I'll hit
enter. You've also then got an
installation scope option. You can
either install it within the project or
at the global level. We'll just do it
within this project for this example.
And then hit enter to proceed with
installation. And that's going to set it
up. So you've now got that agent skill
available within this project directory.
We can now launch a Claude code session
and start building our animation. Before
we jump into Claude code, I've just
opened the project directory up in
cursor so you can have a look at the
project scaffolding. I also just want to
show the HTML file that is our static
infographic. So, I've dragged this into
the project repo as well, so that when
we do prompt claude code, it can access
this file and it has that context to be
able to then build and animate. So,
whatever you're working on, whenever you
want to build and animate into a video,
make sure that those files are also
within this repo so that Claude Code can
access them and edit them. Now, we'll
jump over to our CLI and launch Claude
Code. So, we're back in our CLI. We've
used the claude command to initiate a
new claude code session. And we're going
to start with a pretty basic prompt.
We've got here, look at the HTML file in
project root. Convert this design to a
reotion composition. Start with the
cards appearing one by one with a
stagger animation. Use the remotion
agent skill. So really important to make
sure that we mention the reotion agent
skill. So it looks for that and uses it
for this task. We'll hit enter and let
it execute this first task. So we can
see here claude code worked for 3
minutes and 14 seconds. It invoked that
agent skill and it has executed the task
and provided files and a rundown of the
features that it built. Let's jump over
to dev mode now and test it out. Okay,
so we're in dev mode now. On the left
hand side, you'll see compositions. You
want to locate your video. In this case,
it's benchmark results. Remember, we
started with a static infographic. We
should now have an animated slide where
the cards appear one by one based on the
prompt that we provided. So we can use
this play button here to hit play and
test to see what we've got. So if we do
that, we can see the cards do appear one
by one. So based on our first prompt, it
has executed successfully. We can see
that animation is working. We can now
jump back to Claude Code and continue to
iterate and prompt Claude Code to add
more effects to the animation. So let's
jump back over there. Now we're back in
our Claude Code session now. And for the
next prompt, I'm going to say add a
spotlight phase where each card expands
one by one for narration. When a card is
in spotlight, it should scale up with an
enhanced glow while other cards fade to
15% opacity. Give each card about 3
seconds of spotlight time. I noticed
that in that first one, the animations
were pretty quick, so we're going to be
specific here about the timing and say
to give each card about 3 seconds of
spotlight time and also include smooth
transitions between them. So, that's the
second prompt. We'll hit enter and let
Claude code continue to work. It's
already used the agent skill, so it
should know to invoke that again. Here
you can see Claude code in this case
works for 2 minutes and 18 seconds and
has completed the task. So we'll jump
over to dev mode and test to see if the
spotlight phase is working correctly. So
we're back in dev mode. We'll hit play
shortly and tested. What we should see
now is the first animation take place
where each card appears one by one from
our first prompt. Then we should see the
spotlight phase kick in where each card
will be focused and the other ones will
fade. We'll hit play and we'll see if it
works. There's our first animation from
our first prompt. And here's our
spotlight phase. We can see it's
showcasing each card and making the
other ones fade to the back. It's
holding that spotlight for 3 seconds.
So, it has successfully executed. And
again, we can see how this is really
useful for an animation to use in a
video when you're talking through each
model's results one by one. We'll jump
over and do one final prompt in Claude
Code for another animation and then
we'll wrap things up. So, we're back in
Claude Code. We've confirmed that the
spotlight effect works. I've given
Claude Code one final prompt to add a
couple of other features. Currently, the
cards are left to right and not taking
up too much height. So, I've asked
Claude Code to make the cards vertical
when they're in Spotlight. So, they
should take up more space in that sort
of mobile dimensions infographic that
we've got at the moment. I've also asked
it to add an animation feature to the
numbers. So, when a card comes into
Spotlight, the total number should go up
and we'll see that tick over. So, that's
just another animation effect we're
going to try. We can see Claude Code has
finished. It worked for 2 minutes and 3
seconds. We'll do a final dev mode test
to see how it works. Okay, so we're back
in dev mode. We'll hit play here and see
if it has executed the updates. There's
the first animation from our very first
prompt. We can see now those cards are
expanding vertically and those numbers
are also animated as they get up to the
totals. So, it has executed both of
those features. So, there's a look at
how you can animate videos using plauded
code and the reotion agent skill. The
final step in the process is to export
the video. So once you're happy with the
result and you want to export it, I'll
jump over to the CLI and show you the
command to run to do that. So we're back
in our CLI and we're in our project
directory of Remotion demo. The command
we want to run to export the video is
npx remotion render and then the name of
our video which is benchmark results
out/video.mpp4.
If we hit enter on that, that's then
going to export the video. So we will
then have an MP4 version of that video
that we can then use. We can see it
executing that task here. So that's the
final step in the process. So a few key
takeaways after actually using this
workflow. First, Remotion is best suited
for motion graphics, not full video
editing. You're not going to be able to
cut together a full vlog with it, for
example. But for things like intros,
outros, animated infographics, data
visualizations, social clips, and things
like landing page product demo videos,
it's a really strong option. So, think
of it like After Effects, but driven by
code and prompts instead of timelines.
The iteration loop is fast. You get a
live preview, so you can prompt, check
the result, refine it, and keep going
without long render cycles. In this
video, I was switching between windows,
but in practice, you can run this split
screen and watch animations update in
real time as Claude writes the code. The
agent skill genuinely helps. Claude
wasn't just guessing. It was using
proper animation primitives, sensible
timing, spring animations with
reasonable damping values and clean
composition structure. You're
effectively getting reotion best
practices without needing to learn them
yourself. That said, prompt quality
still matters. Claude isn't reading your
mind. So being specific about timing,
layout, animation phases, and visual
intent makes a noticeable difference in
the output. The bigger idea here is that
anything you can represent as HTML,
JSON, or structured data can now be
turned into a polished animated video
programmatically. That opens up a lot of
possibilities for technical content,
benchmarks, product explainers, and
repeatable visual workflows. I'll leave
the commands and some useful resources
in the description. If you've got
questions or ideas for other workflows
to test, let me know in the comments.
