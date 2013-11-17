
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Classroom Kale</title>

    <!-- Bootstrap core CSS -->
    <link href="https://netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS for the 'Heroic Features' Template -->
    <style>
        body {
            margin-top: 50px; /* 50px is the height of the navbar - change this if the navbarn height changes */
        }
        .hero-spacer {
            margin-top: 50px;
        }

        .hero-feature {
            margin-bottom: 30px;/* spaces out the feature boxes once they start to stack responsively */
        }

        footer {
            margin: 50px 0;
        }
    </style>
  </head>

  <body>

    <nav class="navbar navbar-fixed-top navbar-inverse" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.php">Classroom Kale</a>
        </div>

        <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse navbar-ex1-collapse">
          <ul class="nav navbar-nav">
            <li><a href="/track.html">Track</a></li>
            <li><a href="/recipes.html">Recipes</a></li>
            <li><a href="/contact.html">Contact</a></li>
          </ul>
        </div><!-- /.navbar-collapse -->
      </div><!-- /.container -->
    </nav>
    
    <div class="container">

      <div class="jumbotron hero-spacer">
        <h1>Classroom Kale!</h1>
        <p>Classroom Kale is an Internet-connected terrarium for the classroom. Students can create and share 'recipes' that determin how much water and light the plant receivces, as well as the color of light. Students can track the status of their terrarium in real time with built in temperature and humidity sensorss that sync with their mobile phones.</p>
        <!-- <p><a class="btn btn-primary btn-large">Call to action!</a></p> -->
      </div>
      
      <hr>
      
      <div class="row text-center">

        <div class="col-lg-4 col-md-4 hero-feature">
          <div class="thumbnail">
            <img src="http://placehold.it/800x500" alt="">
            <div class="caption">
              <h3>Program your terrarium</h3>
              <p>Control and experiment with how much water and light (and what color light) your plant gets.</p> 
            </div>
          </div>
        </div>

        <div class="col-lg-4 col-md-4 hero-feature">
          <div class="thumbnail">
            <img src="http://placehold.it/800x500" alt="">
            <div class="caption">
              <h3>Track your terrarium</h3>
              <p>Track your terrarium's temperature and humidity in real time, and keep logs about your plant's health!</p> 
            </div>
          </div>
        </div>

        <div class="col-lg-4 col-md-4 hero-feature">
          <div class="thumbnail">
            <img src="http://placehold.it/800x500" alt="">
            <div class="caption">
                <h3>Share your terrarium</h3>
                <p>Share your recipes, and plant journals with students and classrooms around the world!</p>
            </div>
          </div>
        </div>
      </div><!-- /.row -->
      
      <hr>

      <footer>
        <div class="row">
          <div class="col-lg-12">
            <p>Copyright &copy; Electric Imp 2013 &middot; <a href="http://facebook.com/electricimp">Facebook</a> &middot; <a href="http://twitter.com/electricimp">Twitter</a></p>
          </div>
        </div>
      </footer>
      
    </div><!-- /.container -->

  <!-- javascript -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
  <script src="https://netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>

  </body>

</html>
