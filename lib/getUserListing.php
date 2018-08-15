<?php
        if(empty($_GET['name'])||empty($_GET['place'])){
            echo 'tag info needed: '.$_GET[tag];
        }
        else{
          $tag = trim($_GET["name"]);
          $place = trim($_GET["place"],";");
          require_once('mysqli_connect.php');
          $query = "SELECT listing_id, Title, author, tag, link FROM listings WHERE author = \"".$tag."\" || shared_by = \"".$tag."\"  ORDER BY adjusted_score(score, date_posted) LIMIT ".$place.", ".($place+1).";";
          $response = @mysqli_query($dbc, $query);
          if($response){
                $row = mysqli_fetch_array($response);
                echo '{"title": "'.$row['Title'].'", "link": "'.$row['link'].'", "author": "'.$row['author'].'", "tag": "'.$row['tag'].'", "place": "'.($place+1).'", "id": "'.$row['listing_id'].'"}';
                
            }
            
        }
            
        
    ?>