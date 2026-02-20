---
url: https://www.youtube.com/watch?v=XEiQV4zRC-U
title: Postgres Just Killed Elasticsearch
channel: Tech With Tim
created: 2026-01-22
uploader: Tech With Tim
view_count: 47306
like_count: 1488
comment_count: 86
tags: tech with tim, BM25, TigerData, AI Agents, search function, database, database search, mcp server, ai databases, artificial intelligence database, ai-driven data management, database automation, machine learning in databases, ai-powered data systems, database innovation, ai database tools, data management revolution, intelligent data systems, future of databases, ai system design, data automation tech, database scalability ai, ai data analytics
description: Sign Up for TigerData for free: https://tsdb.co/twt-TigerData
Checkout the GitHub repo for more information: https://tsdb.co/twt-pg-textsearch

If you've ever needed to search for something in a database, you've probably experienced a little bit of pain. In the AI era, search is changing, and even these external tools like Elasticsearch have a lot of problems. Now, the good news is that in this video, I'm going to show you an insanely good solution.

Want to make real money with coding? I share high-signal insights on careers, monetization, and leverage in my free newsletter. Join here and get my guide How to Make Money With Coding instantly: https://techwithtim.net/newsletter

🎞 Video Resources 🎞
Sign Up for TigerData for free: https://tsdb.co/twt-TigerData
Checkout the GitHub repo for more information: https://tsdb.co/twt-pg-textsearch
Blog post/tutorial: https://www.tigerdata.com/blog/introducing-pg_textsearch-true-bm25-ranking-hybrid-retrieval-postgres
TigerData Database Replicas: https://www.youtube.com/watch?v=8cf_bveteOE

⏳ Timestamps ⏳
00:00 | Overview
00:32 | Search is Changing
01:25 | History of Search
03:14 | The Ranking Quality Problem
04:32 | Why BM25 Fixes This (and Why It Matters)
06:45 | Database Search Setup
08:32 | Connecting an MCP Server
11:10 | Search Demo / Examples

Hashtags
#AIAgents #BM25 #TigerData

UAE Media License Number: 3635141
---

If you've ever needed to search for
something in a database, you've probably
experienced a little bit of pain. Now,
if you've used a database like
Postgress, you may have used their
built-in full text search and then
quickly realized that it didn't quite
accomplish the task and switch to
something like Elastic Search, right? An
external tool. But now in the AI era,
search is changing and even these
external tools like Elastic Search have
a lot of problems. Now the good news is
that in this video I'm going to show you
an insanely good solution that's
completely open- source that you can
start using for free today. Now what I'm
going to show you in this video is
something called PG text search and it
brings true BM25 relevance ranked
keyword search directly into Postgris.
Now it lets you do fast highquality text
search without standing up or syncing to
an external search system. You can pair
it with something like PG vector and get
hybrid keyword plus semantic search for
your database all inside of Postgress.
Now, if this sounds confusing, don't
worry. I'm going to clear it up and
explain exactly what it means and also
show you how you can experiment with it
today for free courtesy of Tiger Data
who actually open sourced this
technology and is sponsoring this video.
Now, I'm also going to talk about the
history of search so you can understand
how we're kind of in this new era right
now with AI and how searching has
actually become extremely important and
something that needs to be done a lot
differently that it was done in the
past. Let's dive in. So, for a long
time, search was pretty simple. The
first era was human-facing search,
right? So searching for products, you
know, documentation, blog content, users
typed a few keywords and they expected
relevant results from a relatively
small, mostly static data set. Now,
Postgress handled this extremely well
with its built-in full text search and
TS vector and also TS query. Now, for
thousands or even hundreds of thousands
of documents, it was fast, simple, and
just good enough. Then the search
workloads changed and we entered a
second era where search wasn't just for
humans but for systems. Think like logs,
metrics, event streaming and we have
millions of entries. So ranking the
search results actually mattered less
than scale, speed and aggregation. And
that's where elastic search dominated
and you've probably heard of it or used
it before. Now it wasn't just about
finding documents anymore. It was about
filtering, faceting, and querying
massive constantly changing data sets.
Now that workload required a very
different architecture. Now we're in the
third era which is the AI native
applications era. Search today is
increasingly used by LLMs not just
people. We have rag systems retrieval
augmented generation chatbots and agents
need to search to retrieve the right
context and not just get the matching
documents. Now the data isn't streaming
like logs but the result quality is
critical. Now vector search gives
semantic understanding but it's fuzzy
right and keyword search gives precision
but it's brittle. Now modern AI systems
need both of these and that's the gap
that this new generation of Postgress
native search tools is trying to fill.
Okay. Now let me talk a little bit about
the ranking problem because this is
extremely relevant for AI applications
and it's going to set the tone for the
demo I show you later and why the tool
I'm kind of presenting here is
worthwhile. So for AI applications,
search quality isn't just a nice to
have. It's what directly determines the
output quality. In a rag system, the LLM
can only reason over the documents that
it retrieves. So if your search returns
mediocre matches instead of the best
ones, the model produces mediocre
answers no matter how good the
underlying LLM is. Now this is where
Postgress native full text search starts
to fall apart. Right? Postgress uses
something called TS rank which basically
does keyword matching but it lacks the
ranking signals that modern search
relies on. It doesn't account for how
rare or how meaningful a term is across
the entire corpus. So common words like
database get the same weight as
important terms like pooling. Now it
doesn't prevent keyword repetition from
gaming rankings as well. So long
documents that repeat a term over and
over again tend to float to the top. And
it also doesn't normalize for document
length which unfairly favors longer
documents regardless of how relevant
they actually are. Now there's also a
brittleleness problem. Postgress full
text search relies on boolean matching
meaning all query terms must be present.
If a highly relevant document is missing
just one word it's excluded entirely
before the rankings even begin. Now for
human search that's annoying but for AI
systems it's very damaging. When the
retrieval is weak the entire pipeline
suffers. So hopefully that gave you a
little bit of context about kind of the
native built-in full text search in
Postgress. If you're not aware in the
Postgress database, it has this feature
full text search which is as I just
described. However, there's something
called BM25 and this fixes a lot of
these problems. Now, that's because
modern search engines have solved the
problems that we talked about, right?
Using BM25, which is now the baseline
ranking algorithm across the industry.
Now, BM25 improves keyword search in
three critical ways. First, inverse
document frequency or IDF. This
increases the weight of rare meaningful
terms and downplays the common terms. So
pooling matters more than database or
the and it right and BM25 understands
that. Second term frequency saturation
prevents keyword stuffing. So repeating
a term helps to a point but after that
it adds diminishing returns instead of
dominating the rankings. And then third,
length normalization ensures shorter
focused documents can compete fairly
with longer ones instead of
automatically losing due to size. Now
these ideas aren't experimental. They're
proven production-grade techniques that
power modern search engines. Think
Google, YouTube search, right? They all
use these techniques you've talked
about. Now PG tech search brings this
exact ranking quality into Postgris
without trying to recreate a full search
platform. So this is the feature I'm
going to show you in this video called
PG text search and it focuses on what
Postgris was missing. Highquality ranked
keyword search that pairs naturally with
vector search for AI applications. Now
the result is a cleaner architecture,
one database, better rankings and
retrieval that actually matches how
modern AI systems work. Okay, so that's
the overall kind of understanding that
you need in order for this video to make
sense. Effectively what I'm going to
show you here is a new technique which
is the PG text search which you can add
to a Postgress database which is open
source. I'm going to show you how to add
it, how to experiment with it and why
it's better than just doing a normal
search like you would have had in
Postgress in the past. Hopefully that
gave you a little bit of insight but as
we get into this AI era search is
becoming more and more important and
that's why I wanted to make this video
and I'm going to continue showing how to
set this up. Let's get into it. Okay, so
I'm on the computer and there's a great
article here that comes from Tiger Data
that explains a lot of the stuff in more
depth that I just went over in the intro
there. So, you can see it talks about
the ranking quality gap, right? Talks
about how PG text search works. And what
I'm going to do is I'm going to run
through kind of a modified tutorial that
comes from this document and show you
how you can set up PG Tech Search
directly in your database and how you
can do it for free. Now, in order to do
that, I'm going to be using Tiger Data,
specifically their Tiger Cloud platform
to create a free database. You don't
need to pay for this. You don't need a
credit card. And when you set this up,
you can connect it directly to something
like Cursor and actually use their MCP
server to control the database and run
queries on it. So, you don't need to
manually write them. So, the first step
here, if you want to follow along with
this video, or you can just watch, is go
to Tiger Data. I'm going to leave a link
to it in the description. Make a free
account and then simply just spin up a
free service. So, when you go into the
account, it should prompt you to create
a service. You can select the lowest one
that's free to use and just shuts down
after a few hours if you don't use it.
So, what I'm going to do is go create
service here, and I'm just going to make
this free service in Tiger Data. It's
going to take a second for this to be
spun up. And then what I'm going to be
able to do is use the uh connection
strings here if I wanted just to connect
to this like a normal database. But in
my case, I'm actually going to install
an MCP server inside of Cursor that can
control this database. So we can
directly run queries from our IDE rather
than having to do it directly inside of
uh what do you call it here like you
know a SQL editor. Okay. So once the
service is ready you can just skip the
uh configuration step. You press this
skip this step and you can see that it
has something that allows you to connect
this to an AI tool. So I'm just going to
press on that and it gives me some
instructions that I can use directly
inside of something like cursor or
windserve or wherever you use an MCP
server to directly install it. Now if
you're on Mac it's a little bit easier
than if you're on Windows or if you're
on Linux. So, you can just use Homebrew
or you can just use the script that you
see right here. Follow along with these
steps and then just type tiger mcp
install. However, if you're on Windows,
it's a little bit easier to use it with
go. So, what I'm going to do is follow
the go installation steps, which does
mean you have to have go installed on
your computer. I'm going to show you how
to kind of get it set up and then we'll
start actually working with this new
search. Okay. So, the first command that
it gave me there was this go install and
then just this GitHub repo. So, I'm just
inside a cursor and I'm just going to go
ahead and press enter and install the
Tiger CLI. Okay, so it just finished
installing. Now, let's go back and we
can see the next thing says Tiger O
login. So, let's copy that and paste it.
And now it's just going to bring us to
the Tiger Cloud website. I'm going to
press on authorize and then we should be
good to close this page and return to
our terminal. And let's see. And
validating the API key. And it looks
like we were logged in successfully. So
now what we need to do is just link this
to our project. So you'll see that we
just need to put the uh password here.
So we need to copy this line like this.
So tiger new password, you put the
password and then tiger db save password
and then this is the kind of like the
project name. So I'm going to copy that
and paste it and okay. So inside of
PowerShell, I don't think it works cuz I
need to like set an environment variable
a different way. So I'm just going to
ask cursor how do I run this in
PowerShell. Okay. And just paste it. And
let's see if it can tell me the answer
there. Okay. So it just gave me one line
to run. So I'm just going to copy this
and paste it. Notice I'm just using this
like dollar sign env. And then run. And
it says password saved successfully for
this service. Okay, cool. Now if you're
on Mac or Linux, you could just pasted
that in because it would work for you.
But in my case on Windows, it's a little
bit wonky. And then if I go back here,
let's go back connect AI tool. We can
see the last command is tiger mcp
install. So I'm just going to go ahead
and install this MCP server. You see all
the options here. I'm going to go with
cursor. And when I do that, it should
add this to my cursor installation. And
you can see if I go into my settings
tools and MCP, I have the tiger MCP
server showing up. And now I can start
using cursor. Let's open up a new window
here. And I can ask it to do something
like it says right here, you know, list
my Tiger Cloud services. And it can just
directly list it out for me. So let's
see if it gives me the answer here
running the Tiger MCP server. And you
see I have the time scale database right
here. And it can directly execute SQL
queries. And this also has the cool
feature of being able to actually clone
and replicate the database extremely
quickly if you're working in like dev
versus production environments. Won't
get into that right now because I talked
about it in another video, which I'll
put on screen right now. But what I'm
going to do is I'm going to go to this
guide and I'm going to start showing you
how we can set up kind of a quick
example to actually use this new search
feature that I've been hyping up this
video. So you can see that we have this
kind of demo from coming from this blog
post which I'll link in the description
where we're just creating like an
articles table and inserting some
articles into it and then creating a
search index on that. Now after we
create the search index, this index is
something that is transactional which
means we don't need to modify it. We
don't need to update it. It will just
automatically sync with our database and
then we can start running search queries
on it that will give us a better result
than a fuzzy text search like we had in
kind of the previous version of
Postgress. So because I kind of want to
flex the uh MCP server here because it's
pretty cool. I'm going to copy this.
Again, this is linked in the description
if you want to directly copy this. I'm
going to go to cursor and I'm going to
say using a different example
but the same concept uh you know run a
query similar to this to make some
sample we'll say sample data do 100 rows
okay and I'm just going to paste in the
example and now what it should do is it
should go to tiger data as you can see
it's dbx execute query and it should
make a 100 sample rows for me. So let's
see the first one. Okay, it just created
the table products. Okay, nice. And then
this one I'm going to go just run and it
should insert 100 sample product rows
for me. Okay, cool. And then you can see
that it did that and it just gave me
like a quick uh kind of sample of some
of the data that it inserted into this
products table. So now that we've done
that, we want to create the index. So
I'm going to say same thing for this.
I'm just going to copy this. You can see
the syntax to create the BM25 index. I'm
going to go back here and say, okay, now
do the same modify this
to work
work with our data. Okay. And I'm just
going to paste this here and have it
hopefully execute this query as well.
Okay. So, it actually caught a mistake
that I should have caught myself, which
is that it needed to enable the BM25 um
feature in the database, which is kind
of the most important part. So if we go
here, you can say create extension PG
text search. You need to run that on the
database to actually enable this
feature. So it did that for me
automatically, but this is the first
step. So um anyways, create extension PG
text search. Then you make the sample
data or you know, you could do it
before. It doesn't matter. Then you
create the index, which it just said
that it did. So it said that it made the
index for me. So now I can do an example
test using a select query like this
where I'm going to search through my
products and try to find something. and
let's see the kind of the quality of the
search that we get. So I'm going to go
to cursor and same thing say now adjust
this for search right and just paste
that in and give me some search results
uh you know show me the query and what
we got okay and let's see it execute
that on the database and see the quality
of the search that we're getting. Cool.
So it just executed the query. This is
the query it made. So it said you know
description at to BM uh 25 query. I'll
show you what these mean in a second.
Wireless charging and then product
description index as score. And you can
see that it gave me a bunch of results
where we had wireless mouse pad,
wireless charging stand, wireless
charger stand, wireless charging mat,
wireless charger with all of their
different relevant scores popping up and
all of their different indexes in the
database. And then did another one for
gaming keyboard. And you can see we get
the results here. And this is
significantly better than if you were
using the kind of native before built-in
what is it just like full text search
that uh postcris had compared to now
this pg text search which just works
significantly better. So like that's it.
It just in the database we can now do
search. I don't need an external search
tool. I don't need algolia. I don't need
uh elastic search. I don't need any of
that. I don't need to update a search
index all the time. I literally just
enabled it, created the index, and now I
have a super performant high-end search
directly built inside of Postgress,
which I'm just messing with with an MCP
server, which is kind of crazy that we
even have these features here in 2026.
Now, just to give you some insight into
how this works, if you're looking at the
syntax, right, it kind of explains how
this works. You can use the eyeball
operator, which calculates the BM25
score between the text and the query.
So, ID, title, content, and then we're
calculating the thing, right, as the
score. And then we're just ordering this
by score. So effectively what we've done
is we've said okay so for the content
we'll select the ID, title and content.
But then we're going to do this operator
with all of the content. So as we do
this search and then when we get the
score we can just order this by the
score on the articles and get the top
five. So you're writing a kind of
adjusted SQL query using this BM25
query, right? Which is the search query
which is pretty cool. Now if we keep
going through here, there's a bunch of
other stuff that you can do. So, for
example, you can combine this with
vector search as well. Now, I'm not
going to go through the whole demo
because the video is already a little
bit long. I'll leave this in case you
want to mess around with it on your own,
but you can see that in this case, they
create the index, which is a vector
embeddings index. If you have an LLM,
you could use the embedding model to
create the embeddings and store it in
the database, which they're kind of
doing right here with demo. And then
you're able to run some more advanced
queries, right? Where you're using the
vector search as well as using the text
search. You can combine both together,
right? Where you're doing first, okay,
the vector search, then on the vector
search, we do the keyword search within
that. And we can get some pretty cool
results, which is what they're calling
hybrid search. And again, it goes into
more details in this article, which I
will link in the description in case
you're curious about kind of how to get
the best performance out of this. This
is super cool. It works extremely well,
very easy to set up, free, open source
to use, right? I just showed you an
example inside of Tiger Data here
because that's how I was able to get it
up and running very quickly. Massive
thank you to them for sponsoring the
video and making this technology
available to everyone. Let me know what
you guys think of this in the comments
down below, and I will see you in
another video.
