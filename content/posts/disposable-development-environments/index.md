---
title: Disposable development environments with gitpod
date: 2020-10-31T15:35:10+02:00
categories: [programming]
tags: [cloud,development-environment]
description: how to setup a new gitpod disposable development environment for running a hugo powered blog
draft: false
---

This blog post is completely written in a web browser running [gitpod](http://gitpod.io), which allows you to setup your 
development environment in the cloud. And you can try it out yourself by following this link: [katmatt/katmatt-blogs](https://gitpod.io/#https://github.com/katmatt/katmatt-blogs).

If you click that link, it will open up the github project for my blog, start a [hugo](https://gohugo.io/) server and offers you to open a preview of my blog:
{{< figure src="gitpod-inception.png" >}}
This feels a bit like in the movie [inception](https://en.wikipedia.org/wiki/Inception), where the protagonists travel from a dream to another dream. And on each level the time slows down. 

The difference in this simile is that using gitpod accelerates your work: If you have to work on a bug fix on an old version of your project, gitpod will make sure that your development environment is set up as it was configured for that version/git ref of your project!

It feels like inception especially in the screenshot above: it shows you the preview of this blog post while I'm writing it in gitpod. 
I still have to get my head around it and especially working with an editor/IDE running in my web browser still feels a bit strange to me.

# How does it work?

You can open up any project that is hosted either on [gitlab](https://about.gitlab.com/), [github](http://github.com) or [bitbucket](https://bitbucket.org/)
by adding the repository url to the following gitpod url `http://gitpod/#<YOUR_GIT_REPO_URL>`. 

And that's just the beginning: If you use this link for the first time, gitpod will open a wizard that helps you to setup your development environment. When you used the link to my blogs gitpod development environment, then gitpod already started a development environment for you that contains everything to write a blog post.

# What is a development environment?

I normally write my blog post on my laptop that runs ubuntu linux. I use hugo to generate my
blog from markdown files and I use github actions to publish my finalized blog to github pages: [katmatt-blogs/.github/workflows/main.yml](https://github.com/katmatt/katmatt-blogs/blob/master/.github/workflows/main.yml). 

That means that I already set up a continuous integration build to automate everything.
But what's missing is a setup of my local development environment. In the case of my blog, it's relatively simple because I can install hugo with one command. But in a typical SW development project, I would have to setup multiple tools to build the project locally. And this setup is typically written down in prose in a readme file, needs to be updated manually, and tends to be outdated very quickly. It would be much easier if this description would be machine-readable and if a machine could precisely provision the same development environment for each team member. 

# Disposable development environments with gitpod

And that's what gitpod offers: It runs your development environment in the cloud. The gitpod team calls this concept disposable development environments.

And to setup such a development environment with gitpod, you have to describe your development environment in a `.gitpod.yml` file located in the root of your project. 
And this `.gitpod.yml` file looks like this for my blog:
```yaml
image: klakegg/hugo:0.68.3-ext-alpine
tasks:
  - command: hugo server --baseUrl $(gp url 1313) --liveReloadPort=443 --appendPort=false
```
The first line specifies the docker image that contains hugo. And on the following line, I define the task to run
when opening my development environment. And for my blog I just need to run the hugo server command to be able to see a preview of my blog in gitpod.
This command is a bit more complex because we have to call the gitpod CLI tool `gp` to get the url where our hugo server is running and because gitpod
uses https for serving the content, we also have to set the `liveReloadPort` argument.

# Conclusion

My small example just scratches the surface of what gitpod offers. And the gitpod team developed their awesome product by using gitpod themselves - 
an idea that is very common for SW tool companies and is called [eating your own dog food](https://en.wikipedia.org/wiki/Eating_your_own_dog_food).

And they shared how they develop gitpod in gitpod in this great video:
{{< youtube dFMpXUsJcGM >}}

Although I initially had some issues with having my IDE in the browser, I now see a lot of potential: Our team reviews pull request on github by using the builtin diff view. And I seldomly checkout a PR branch, although it would provide much more context. Imagine you just click a link and then the development environment for that branch/PR immediately opens in your browser. And you can navigate the source code, run tests and may even be able to run the system under development. 

gitpod is a game-changer and I highly recommend you to give it a try yourself!