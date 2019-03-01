<p align="center"><img src="assets/static/images/logo/vertical.png" alt="cotoami" height="200px"></p>


[![CircleCI](https://circleci.com/gh/cotoami/cotoami.svg?style=svg)](https://circleci.com/gh/cotoami/cotoami)

Cotoami (言編み・言網) is a platform where people can weave a large network of wisdom from tiny ideas.


## Screenshots

### Flow (timeline) and Stock (structured content)

![](docs/images/timeline-and-pinned-docs.png)

## Stock rendered as a graph

![](docs/images/timeline-and-graph.png)

## Fully usable on mobile devices

![](docs/images/screenshot-mobile.png)

## Concept Mapping

[What is a Concept Map?](http://cmap.ihmc.us/docs/conceptmap.php)

![](docs/images/concept-map.png)

The screenshot above is an example of a concept map explaining why we have seasons (originally presented in the article at Concept Maps official website: http://cmap.ihmc.us/docs/theory-of-concept-maps).

If you are interested in how this concept map was created with Cotoami, here is a youtube video to demonstrate the process: "Making a concept map with Cotoami" - https://www.youtube.com/watch?v=YYQrsGnSoLU


## Concept

In Cotoami, you post your ideas and thoughts like chatting. The timeline actually has a chatting feature where you can chat with other users sharing the same space.

![](docs/images/anime/anime1-posting-cotos.gif)

You would feel free to write anything that comes in your mind. Your posts just flow into the past unless they are pinned:

![](docs/images/anime/anime2-pin-cotos.gif)

Then you make connections to enrich your stock (there are two panes side by side representing [flow and stock](http://snarkmarket.com/2010/4890) respectvely).

![](docs/images/anime/anime3-connect.gif)

### Basic building blocks

Individual posts are called "Cotos", which is a Japanese word meaning "thing", and there's a special type of Coto called "Cotonoma" (Coto-no-ma means "a space of Cotos"). A Cotonoma is a Coto that has a dedicated chat timeline associated with it. These two concepts are basic building blocks of a knowledge base in Cotoami.

![](docs/images/cotonoma.png)

As you can see in the image above, Cotonomas are posted to a timeline like Cotos. Actually, you can treat Cotonomas as Cotos. They can be pinned to another Cotonoma or connected to other Cotos.

### Cotoami's concept of knowledge generation

![](docs/images/cotoami-concept.png)

1. Collect random ideas by posting Cotos to a timeline.
2. Look for connections between Cotos and make them as they are found.
3. Cotonomatize: Convert a hub Coto that has many outbound connections and looks worth discussing into a Cotonoma.
4. Repeat the same thing in the new Cotonoma.

### Cotonomatizing

During a process of chatting, posting random ideas, and creating structured content by connecting Cotos, some Cotos would collect more connections than others. Those Cotos are possibly important to you or your team and worth discussing as focus questions. Cotonomatizing allows you to convert them into Cotonomas to make the process recursive.

![](docs/images/cotonomatizing.png)

### Linking Phrases

Since the version 0.21.0, you can annotate connections. The term "Linking Phrases" is borrowed from Concept Maps. Actually you can create concept maps with this feature as introduced in the [Screenshots / Concept Mapping](#concept-mapping) section above.

![](https://user-images.githubusercontent.com/764015/53540799-4effe780-3b5a-11e9-8b3a-7dc463aecdc9.png)

Cotonomas (Cotonomatizing) and Linking Phrases are the most two important features so far in Cotoami. 

Why is the Linking Phrases feature so important? Concept mapping is a good way to demonstrate this feature, but an important difference is that Cotoami's linking phrases are optional. That means you should avoid annotating connections unless the relationships are obscure to you. Those obscure relationships are possibly valuable knowledge for you (since you didn't know them well before), and should be highlighted in your knowledge-base (that's why annotated connections are rendered so that they stand out). I personally call them **Horizontal Relationships**.

On the other hand, **Vertical Relationships** generally means inclusive or deductive relationships like "includes", "results in", or "is determined by". Simple arrow lines would be enough to express these relationships and you wouldn't feel the need for annotations in most cases.

Which connection is vertical or horizontal depends on you like Cotonomas are emerged concepts during your knowledge creation. Horizontal relationships (annotated connections) are important portion of the discoveries in your knowledge-base.


## Try it

### Demo server

There's a server only for demonstration purposes: https://demo.cotoa.me

It may be slow to respond at first because it's run by Heroku free plan (which puts unused apps to sleep).

### Launch your own server with Docker

* [Install Docker Desktop for Mac \| Docker Documentation](https://docs.docker.com/docker-for-mac/install/)
* [Install Docker Desktop for Windows \| Docker Documentation](https://docs.docker.com/docker-for-windows/install/)

The easiest way to launch your own Cotoami server is to use Docker. If you have a Docker environment running 
(`docker info` outputs some info), just one single command below will launch a whole environment, which contains an app server and several backend services, with default configuration:

```
$ wget -qO - https://raw.githubusercontent.com/cotoami/cotoami/master/launch/run.sh | bash
```

At the end of the launching process, something like the following should be output to the console:

```
...
Cotoami will be ready at http://192.168.99.100:4000
You can check sign-up/in mails at http://192.168.99.100:8080
```

If there are no errors, you should be able to open the start page at the URL in the log (it may be take some time for the servers to start up completely).

If you want to stop the servers, execute the following command in the same directory:

```
$ docker-compose stop
```

Your data will be stored in Docker's named volumes: `cotoami_postgres-data`, `cotoami_neo4j-data`.
You can view the detail information by:

```
$ docker volume inspect cotoami_postgres-data
$ docker volume inspect cotoami_neo4j-data
```

### Official server

Cotoami project also runs a fully-managed official server. You can get an account of it by becoming a patron at https://www.patreon.com/cotoami

If you are interested in using it or supporting the project, please consider becoming a patron 😉


## Deploy to Heroku

You can deploy Cotoami to your Heroku account with the Heroku Button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

On the "Create New App" page, set the app name and replace the highlighted values with your custom values:

![](docs/images/cotoami-heroku-configs.png)

* `SECRET_KEY_BASE`
    * Specify a random 64-bytes-long string.
        * e.g. `Y/j0csZXyV2On8uX1TIZXAkR6K8w45egzL76xIV/6jyfPuaZ5A5j5mAtoTsMw3CE`
* `SENDGRID_API_KEY`
    * This is a tricky part of the deployment. You need to obtain a SendGrid (an email sending service) API key by following the instructions in the "Obtain a SendGrid API key" section below.
* `COTOAMI_URL_HOST`
    * Replace `<app-name>` with your Heroku app name.
* `COTOAMI_OWNER_EMAILS`
    * Specify owner email addresses (comma separated).

You should know the limitations of Cotoami on Heroku as described in: https://hexdocs.pm/phoenix/heroku.html#limitations
    
### Obtain a SendGrid API key

1. First, you need to get SendGrid's username and password by deploying an app (Click the "Deploy app" button in the Heroku site).
2. After finishing the deployment, you can check your username and password via config vars: `SENDGRID_USERNAME` and `SENDGRID_PASSWORD`, which can be viewed in the app's settings page in the Heroku site (click the "Reveal Config Vars" button).
3. Go to <https://app.sendgrid.com/settings/api_keys> and log in with the username and password.
4. Create an API key.
5. Set the obtained key to the config `SENDGRID_API_KEY` in the Heroku app's settings page (then the app will restart automatically).

* ref. [SendGrid \| Heroku Dev Center](https://devcenter.heroku.com/articles/sendgrid)


## Related URLs

* News and updates - https://twitter.com/cotoami
* Docker images - https://hub.docker.com/r/cotoami/cotoami/


## Special Thanks

* Sponsored by [UNIVA Paycast](https://www.univapay.com) until Aug 2018.
* The logo is designed by [@reallinfo](https://github.com/reallinfo)
    * https://github.com/cotoami/cotoami/pull/107


## License

Cotoami source code is released under Apache 2 License.

Check [LICENSE](LICENSE) file for more information.
