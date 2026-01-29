## Step 1
I want to deploy a sandbox (docker container) with VIM and integrate AI to my development process without exposing my local filesystem to the AI in direct way.

I wish to:
* Have a vim container with AI integrated
* Have as many sidecar containers as needed to deploy a local llm to help with coding and remote AI agents
* Have a quick readme on how to use the AI or access to the help pages
* Have the needed vimrc configuration file(s) to configure them
  * Use `\` (backslash) as a leader character
* Have key directories persist across container deletions etc, using *directories* and **not volumes** as the means to do so
* Use a local user to run within the containers, whose UID and GID must much my own

Provide me with an archive containing the following
- The required Dockerfiles and docker-compose files to easily build and run such an environment
- vimrc to insert into the container
- script(s) or commands in readme format needed to set environment variables appropriately

