---
url: https://www.youtube.com/watch?v=m6itCxJFqpo
title: Zero-Setup RLMs with Claude Code
channel: Brainqub3
created: 2026-01-18
uploader: Brainqub3
view_count: 14264
like_count: 521
comment_count: 59
tags: claude ai, ai agents, claude mcp, model context protocol, mcp servers, ai hallucinations, claude desktop, agentic ai, anthropic claude, enterprise ai, ai fact checking, generative ai, large language models, ai automation, ai consulting, business ai, ai verification, ai tools, artificial intelligence, claude code, gemini 3, gpt-5.1, chatgpt, michael burry, NVIDIA, AI BUBBLE, data quality, startup, fact check, legal tech, legal ai, ai transformation, agents, automation
description: 🔗 AI Consulting: https://brainqub3.com/

Recursive Language Models (RLMs) in Claude Code
An open-source implementation of Recursive Language Models using Claude Code primitives. If you've read the RLM paper and want to experiment with recursive approaches to language model reasoning, this repo lets you get started with minimal setup.

📦 Getting Started
Just install Claude Code and you're ready to go - no additional dependencies or configuration required.
🔗 Links

GitHub Repo: https://github.com/brainqub3/claude_code_RLM
RLM Paper: https://arxiv.org/pdf/2512.24601v1


About This Channel
I build production AI applications and share what I learn. Subscribe for practical tutorials on AI engineering, agents, and infrastructure.
🔗 Connect

Brainqub3 Check (AI Fact-Checker): https://check.brainqub3.com

#AI #ClaudeCode #RLM #AIAgents #LLM
---

If you read the RLM's paper, are you
excited about recursive language models
in general and you want to play around?
I've got the thing for you. An
implementation of RLMs using claw code
primitives repo is available open
source. If you want to try it for
yourself, no need for any additional
setup apart from installing claude code.
Let's go. So, I had this idea to set up
the RLM in the claw code harness and
that's because all of the primitives are
pretty much already available to us. So
we have the ability to call the sub LLM
using the sub aents capacity and clawed
code and we can treat the main claw code
instance as the root LLM call. So what
I'm going to do is I'm just going to
take you through the repo very quickly
and this repo is publicly available. So
by the time this video comes out it'll
be available to you. There's some
instructions but all you'll need to do
is clone this and you will have this
recursive language model set up
available to you. All right. So
everything uses claude or anthropic
primitives. We've got the claude file
which if you have used
claude before you will be familiar with
and we have our skills setup. So we have
our agent setup and we have our skill
setup. So within the agent setup, we
have the rlm subcore domarkdown and all
that is is instructions that the agent
follows to use the ripple script to
search over context. Then within our
skills we have some scripts and the
script here is the ripple. So ripple is
the read evaluate print loop and that's
the core of your recursive language
model setup and this is just a simple
Python script. It's about 400
I think it's yeah it's about 400 lines
long and that just gets the agent to run
that ripple and then we have the
skill.md and this is kind of your
procedural stuff. So this is picked up
by the sub agent to run that procedure.
So to run this ripple script. That's all
it does. So it's pretty basic. Stepping
back up to the top, we have the
claude.md.
Let's find that. And this is highle
instructions for Claude. And as you can
see, very concise. We want to keep this
as bare as possible because Claude is
going to be doing a lot of the heavy
lifting and delegating. So we want to
keep it really high level and abstract.
In fact, it's a good idea to think about
your claude MD files like your executive
file. So as you know, if you're working
with your executive, you wouldn't give
your executive a ton of detail. You give
them a highle task. Um they like to see
things at a high level. So does the
claude MD. So keep the detail out of
here and just give it the highle
abstractions it needs to execute a
workflow. It's got awareness of the
skills available, the sub agent to
delegate that skill to, and then you've
got the persistent Python ripple. So
that's just the Python script that is
used to execute that ripple
process.
And then this are kind of procedural
instructions in how to interact with the
users. That's it. Setup is very basic.
Here's what we're going to test it on.
We have sourced some public merger
agreements. I'm going to open the one
we're using. So, we're using the Amazon
and Whole Foods one. So, caveat here.
I'm not a lawyer. So, I cannot validate
any of this output. This is merely to
demonstrate how Claude code can be used
as a harness for the RLM. So, let's open
the Amazon one so you get an idea of
what this thing looks like. So, if
you've read the RLM paper, you'll
understand that there's two dimensions
to this. So, there's document length.
We're dealing with large context. You
can see this is pretty large context. I
wouldn't say hugely because, you know,
I'd say something that's much bigger
would be a data room, for example, with
maybe hundreds of documents. But this is
fairly large context just for a single
LLM call. But more importantly, it's
high complexity because this is some
kind of merger agreement contract.
So that's what we're operating on. I
have already put that inside the clawed
code instance. So what I'm going to do
now is I'm going to pull up my instance
of claw code which I'm going to run in
dangerously
skip
permissions
mode. So that's just so I don't have to
keep pressing enter and keep approving
Claude to make edits. So it's just going
to go and do that itself. Okay. So we're
in. Right. So the first thing you want
to do is you want to do the / RLM. But
actually before I do that, let me just
show you the setup. So in here you have
your agents. And if I jump into my
agents, you can see there I've got the
RLM subcore agent. So that's running off
Claude Haiku. And the reason we set that
to a smaller agent because all it's
doing is it's doing search over that
memory object. So the way this works
very very high level because I've
already done ton of detail on it is
instead of getting Claude to process all
of that long context in one shot. What
we do is we virtualize it by assigning
it to some kind of Python object and
then we run that ripple loop over it and
we use haiku to run that rep ripple loop
over it and that enables us to process
that context programmatically rather
than forcing the LLM and effectively
what it's going to do is it's going to
run various operations on it like
slicing reg x and all of those types of
things. Okay, cool.
So that's the agent. You can see it's
already in there. Now, let's jump
straight in to executing this RLM flow.
So, this will obviously flow straight
through to the claw MD. And this is what
claw MD tells us to do. So, this is the
executive level. So, all it needs to get
started is a file path. And I've already
saved that contract down in a in a
folder in this project. And you'll have
that available to you as well if you
want to experiment. Give a query as
well. So actually I had a query
available in the chat GBT chat. I'm
going to bring that up because again I'm
not a lawyer. So I cannot validate any
of this stuff. But good news is we have
a research paper to say that it actually
works. So I'm going to pick one of these
queries. I'll probably use one. I have
no idea what any of this stuff is. So
let me just see. Let's just pick one.
Let's pick this.
What are the conditions precedent to
closing for each party? All right, let's
pick that up and let us pull up our claw
code instance. So the first thing we'll
say is
the context
is located. Let's save as ex. Here it
is. So that's the context. That's that
legal contract that we pulled up
earlier. And then this is the query. So
I'm going to put it in tags. I don't
think you need to, but this is just the
way I am now used to prompting. Okay,
let's do that. So I think this is a
relic personally, the tags, but you
know, it's just muscle memory for me at
this stage. So we'll wait and we'll see
how Claude works through this. So it's
already recognized it wants to start the
RLM workflow which is positive and
that's what we want to hear or that's
what we want to read. So it's
initializing the report and scouting the
context. Okay, you can see it's actually
executed that in Python. Okay,
so what it's done here is it's
virtualized that memory. You can see
that pickle and it's counted the
characters. We've got 429,000
characters. This is exactly what it
should be doing at this stage. It's
notice it hasn't ingested all of that
content. That's the main thing to notice
here. So here it's having a peak. So
this is the Nvidia ARM share purchase
agreement. Oh, so apologies. I think I
showed you the Amazon one at the
beginning, but actually I'm using the
Nvidia share purchase agreement. So
apologies for that. That was a little
mistake at the start, but same
difference. doesn't matter. It will all
be in the repo for you to play around
with yourselves. So, let me search using
basic Python string operations. At some
stage, I'm hoping to see a handoff. You
see, notice this is how it's processing
context programmatically. It's not
trying to reason over such a large
context which would induce the context
rot. What it's doing is it's locating
those sections by performing Python
operations on the virtualized memory and
you know this is pattern matching. This
is like reg x this is slicing in that
way. Okay. So it's found the areas that
it needs to pay attention to. So it's
saying let me find actual content of
article 7 and create chunks for the sub
agent to analyze. So that's good. That's
what we want. Let's see how it's handing
off to sub Asian already. Hopefully,
this should actually bring to life how
much more sophisticated this is than rag
because imagine trying to do this with
rag. You just have a similarity search,
some kind of semantic similarity search
or keyword match which would not have
the flexibility. So, I think it's as
always with live demos, it's found the
observation, it's found the answer from
that contract without actually having to
use the sub agent. So, I mean, that's
great to be honest with you. That's
fantastic. And you know, why use more
compute than you need to? But yeah,
again, I was hoping that it would step
into the sub agent. Just so you know, I
have run examples of this where it did
step into the sub agents and all
allocate tasks, but perhaps it was just
able to find it without doing that. So,
here you go. That is what you get. And
that's how quick it is to work through
that and find the right clauses.
I'm not going to read any of this
because I'm not a lawyer and I can't
validate it. But I would invite anyone
that is who wants to play around with
this to get on it and see if it actually
holds up in production.
