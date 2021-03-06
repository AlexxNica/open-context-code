<?php


//this class interacts with the database for accessing projects items
class Projects {
    
	 public $frontendOptions = array(
					  'lifetime' => 720000, // cache lifetime, measured in seconds, 7200 = 2 hours
					  'automatic_serialization' => true
			);
					  
	  public  $backendOptions = array(
				 'cache_dir' => './time_cache/' // Directory where to put the cache files
			);
    
	 public $projectList;
	 public $projectsJSON;
	 const TMmaxTitleNames = 4; //number of context names to list in a title
	 const TMmaxSize = 12;
	 const TMminSize = 1;
	 public $forceTheme = false;
	 
	 function getMakeTimeMap(){
		  
		  $host = OpenContext_OCConfig::get_host_config();
		  $cache = Zend_Cache::factory('Core',
                             'File',
                             $this->frontendOptions,
                             $this->backendOptions);
		  
		  $cacheID = "timemapObj";
		  if(!$cache_result = $cache->load($cacheID)) {
				$this->DBgetProjects(); //get list of projects from the database
				$projectsJSON = $this->projectsJSON(); //get JSON metadata for all projects
				$timeMapObj = $this->makeTimeMapObject($projectsJSON); //convert project metadata to the TimeMap object
				return $timeMapObj;
		  }
		  else{
				return $cache_result;
		  }
	 }
	 
	 
	 /*
	  convert the project's JSON metadata into the structure needed for TimeMap
	  Because timemap is a visualization tool, we need to preprocess the raw project metadata
	  into a form that is easier to visualize for users.
	 */
	 function makeTimeMapObject($projectsJSON = false){
		  
		  $timeMapObj = false;
		  if(!$projectsJSON){
				$projectsJSON = $this->projectsJSON;
		  }
		  
		  if(is_array($projectsJSON)){
				
				$chrome = true;
				$useragent = @$_SERVER['HTTP_USER_AGENT'];
				if(stristr($useragent, "chrome")){
					 $chrome = true;
				}
				
				$maxContextCount = 0;
				
				$workingContexts = array(); //limit number of contexts that have the same timespans
				$workingSort = array();
				$timeMapObj = array();
				foreach($projectsJSON as $project){
					 if($this->keyArrayCheck("contexts", $project)){
						  foreach($project["contexts"] as $actContext){
								$timeSpanHash = md5(($project["uri"]."-".$actContext["geoTime"]["timeBegin"])."-".($actContext["geoTime"]["timeEnd"]));
								if(!array_key_exists($timeSpanHash, $workingContexts)){
									 $workingContexts[$timeSpanHash] = array("count"=> 1,
                                                      "used"=> false,
                                                      "start"=> $actContext["geoTime"]["timeBegin"],
                                                      "end" => $actContext["geoTime"]["timeEnd"],
																		"prep-geo" => array(
																						  "minLat" => $actContext["geoTime"]["geoLat"],
																						  "minLon" => $actContext["geoTime"]["geoLong"],
																						  "maxLat" => $actContext["geoTime"]["geoLat"],
																						  "maxLon" => $actContext["geoTime"]["geoLong"]),
                                                      "itemTotal" => $actContext["count"],
                                                      "title" => $actContext["name"],
																		"point" => array("lat" => $actContext["geoTime"]["geoLat"], "lon" => $actContext["geoTime"]["geoLong"])
                                                      );
									 
									 $innerHTML = "<div class=\"info-box\">";
									 $innerHTML .= "<div class=\"info-tab\">";
									 $innerHTML .= "<div class=\"info-row\">";
									 $innerHTML .= "<div class=\"info-icon-cell\"><img src='../images/item_view/project_icon.jpg' border='0' ></img>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "<div class=\"info-t-cell\">";
									 $innerHTML .= "As part of the <a href='".$project["uri"]."'><em>".$project["label"];
									 $innerHTML .= "</em></a> project, <strong>".$workingContexts[$timeSpanHash]["title"]."</strong> contains ".$actContext["count"]." items.";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "<div class=\"info-browse\">";
									 $innerHTML .= "[<a href='".$project["href-proj-sets"]."'>Click here</a>] to browse in this project.";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 
									 $workingContexts[$timeSpanHash]["options"]["infoHtml"] = $innerHTML;
									 
								}
								else{
									 //multiple contexts 
									 $workingContexts[$timeSpanHash]["count"]++;
									 
									 if($workingContexts[$timeSpanHash]["count"] < self::TMmaxTitleNames){
										  $workingContexts[$timeSpanHash]["title"] .= ", ".$actContext["name"];
									 }
									 elseif($workingContexts[$timeSpanHash]["count"] == self::TMmaxTitleNames){
										  $workingContexts[$timeSpanHash]["title"] .= ", etc.";
									 }
									 
									 $workingContexts[$timeSpanHash]["itemTotal"] +=  $actContext["count"];
									 
									 if($actContext["geoTime"]["geoLat"] < $workingContexts[$timeSpanHash]["prep-geo"]["minLat"]){
										  $workingContexts[$timeSpanHash]["prep-geo"]["minLat"] = $actContext["geoTime"]["geoLat"];
									 }
									 if($actContext["geoTime"]["geoLong"] < $workingContexts[$timeSpanHash]["prep-geo"]["minLon"]){
										  $workingContexts[$timeSpanHash]["prep-geo"]["minLon"] = $actContext["geoTime"]["geoLong"];
									 }
									 if($actContext["geoTime"]["geoLat"] > $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"]){
										 $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"] = $actContext["geoTime"]["geoLat"];
									 }
									 if($actContext["geoTime"]["geoLong"] > $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"]){
										 $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"] = $actContext["geoTime"]["geoLong"];
									 }
									 
									 
									 unset($workingContexts[$timeSpanHash]["point"]);
									 
									 if(abs(($workingContexts[$timeSpanHash]["prep-geo"]["minLon"] + $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"])/2) < 3 && abs(($workingContexts[$timeSpanHash]["prep-geo"]["minLat"] + $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"])/2) < 3){
										  $workingContexts[$timeSpanHash]["point"] = array("lat"=> ($workingContexts[$timeSpanHash]["prep-geo"]["minLat"] + $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"])/2,
																									"lon"=> ($workingContexts[$timeSpanHash]["prep-geo"]["minLon"] + $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"])/2);
									 }
									 else{
										   $workingContexts[$timeSpanHash]["point"] = array("lat"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLat"],
																									"lon"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLon"]);
									 }
									 
									 unset($workingContexts[$timeSpanHash]["polygon"]);
									 
									 
									 if(abs($workingContexts[$timeSpanHash]["prep-geo"]["minLat"] - $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"]) < 5 && abs($workingContexts[$timeSpanHash]["prep-geo"]["minLon"] - $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"])<5){
										  $workingContexts[$timeSpanHash]["polygon"] = array();
										  $workingContexts[$timeSpanHash]["polygon"][] = array("lat"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLat"],
																										 "lon"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLon"]);
										  $workingContexts[$timeSpanHash]["polygon"][] = array("lat"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLat"],
																										 "lon"=> $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"]);
										  $workingContexts[$timeSpanHash]["polygon"][] = array("lat"=> $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"],
																										 "lon"=> $workingContexts[$timeSpanHash]["prep-geo"]["maxLon"]);
										  $workingContexts[$timeSpanHash]["polygon"][] = array("lat"=> $workingContexts[$timeSpanHash]["prep-geo"]["maxLat"],
																										 "lon"=> $workingContexts[$timeSpanHash]["prep-geo"]["minLon"]);
									 }
									 
									 $innerHTML = "<div class=\"info-box\">";
									 $innerHTML .= "<div class=\"info-tab\">";
									 $innerHTML .= "<div class=\"info-row\">";
									 $innerHTML .= "<div class=\"info-icon-cell\"><img src='../images/item_view/project_icon.jpg' border='0' ></img>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "<div class=\"info-t-cell\">";
									 $innerHTML .= "As part of the <a href='".$project["uri"]."'><em>".$project["label"];
									 $innerHTML .= "</em></a> project, there are several contexts including: <strong>".$workingContexts[$timeSpanHash]["title"]."</strong>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 $innerHTML .= "<div class=\"info-browse\">";
									 $innerHTML .= "[<a href='".$project["href-proj-sets"]."'>Click here</a>] to browse in this project.";
									 $innerHTML .= "</div>";
									 $innerHTML .= "</div>";
									 $workingContexts[$timeSpanHash]["options"]["infoHtml"] = $innerHTML;
									 
								}//end case where we're adding to an existing context display
								
								if($workingContexts[$timeSpanHash]["itemTotal"] > $maxContextCount){
									 $maxContextCount = $workingContexts[$timeSpanHash]["itemTotal"];
								}
								
								$workingSort[$timeSpanHash] = $workingContexts[$timeSpanHash]["itemTotal"];
						  }//end loop through contexts
						  
						  if(count($project["contexts"])== 0 && $project["editStatus"] == 0){
								
								$innerHTML = "<div class=\"info-box\">";
								$innerHTML .= "<div class=\"info-tab\">";
								$innerHTML .= "<div class=\"info-row\">";
								$innerHTML .= "<div class=\"info-icon-cell\"><img src='../images/item_view/project_icon.jpg' border='0' ></img>";
								$innerHTML .= "</div>";
								$innerHTML .= "<div class=\"info-t-cell\">";
								$innerHTML .= "The <a href='".$project["uri"]."'><em>".$project["label"];
								$innerHTML .= "</em></a> project is forthcoming.";
								$innerHTML .= "</div>";
								$innerHTML .= "</div>";
								$innerHTML .= "</div>";
								$innerHTML .= "</div>";
								
								$workingContext = array("count"=> 1,
                                                      "used"=> false,
                                                      "start"=> $project["draftGeoTime"]["timeStart"],
                                                      "end" => $project["draftGeoTime"]["timeEnd"],
																		"prep-geo" => array(
																						  "minLat" => $project["draftGeoTime"]["minLat"],
																						  "minLon" => $project["draftGeoTime"]["minLon"],
																						  "maxLat" => $project["draftGeoTime"]["maxLat"],
																						  "maxLon" => $project["draftGeoTime"]["maxLon"]),
                                                      "itemTotal" => 0,
                                                      "title" => "Forthcoming: ".$project["label"],
                                                      "options" => array(
																								"infoHtml" => $innerHTML,
																								"theme" => "forthcoming"
																						  )
                                                      );
								
								$workingContext["point"] = array("lat"=> ($workingContext["prep-geo"]["minLat"] + $workingContext["prep-geo"]["maxLat"])/2,
																		  "lon"=> ($workingContext["prep-geo"]["minLon"] + $workingContext["prep-geo"]["maxLon"])/2);
								
								if(abs($workingContext["prep-geo"]["minLat"] - $workingContext["prep-geo"]["maxLat"]) < 5 && abs($workingContext["prep-geo"]["minLon"] - $workingContext["prep-geo"]["maxLon"])<5){
									 $workingContext["polygon"] = array();
									 $workingContext["polygon"][] = array("lat"=> $workingContext["prep-geo"]["minLat"],
																					 "lon"=> $workingContext["prep-geo"]["minLon"]);
									 $workingContext["polygon"][] = array("lat"=> $workingContext["prep-geo"]["minLat"],
																					 "lon"=> $workingContext["prep-geo"]["maxLon"]);
									 $workingContext["polygon"][] = array("lat"=> $workingContext["prep-geo"]["maxLat"],
																					 "lon"=> $workingContext["prep-geo"]["maxLon"]);
									 $workingContext["polygon"][] = array("lat"=> $workingContext["prep-geo"]["maxLat"],
																					 "lon"=> $workingContext["prep-geo"]["minLon"]);
									 unset($workingContext["polygon"]);
								}
								
								$workingContexts[md5($project["uri"])] = $workingContext;
								$workingSort[md5($project["uri"])] = 0;
								unset($workingContext);
						  }//end case with 0 count countexts and forthcoming status
					 }//end case with contexts
				}//end loop through projects
				
				//now sort by the number of items, decenting order..
				arsort($workingSort);

				//fix size, help out chrome with intelligible json
				foreach($workingSort as $key => $sortValue){
					 $actContext = $workingContexts[$key];
					 unset($actContext["prep-geo"]);
					 unset($actContext["count"]);
					 unset($actContext["used"]);
					 $actContext["used"] = true;
					 
					 if($chrome){
						  if(($actContext["start"] + 0) < 0){
								$actContext["start"] = abs($actContext["start"] + 0)." BC";
						  }
						  else{
								$actContext["start"] = (string)$actContext["start"];
						  }
						  if(($actContext["end"] + 0) < 0){
								$actContext["end"] = abs($actContext["end"] + 0)." BC";
						  }
						  else{
								$actContext["end"] = (string)$actContext["end"];
						  }
					 }
					 $actSize = $this->TMassignSize($actContext["itemTotal"], $maxContextCount);
					 $actContext["options"]["size"] = $actSize;
					 if(!isset($actContext["options"]["theme"])){
						  $actContext["options"]["theme"] = "theme-size-".$actSize;
					 }
					 //unset($actContext["options"]["theme"]);
					 if($this->forceTheme){
						  $actContext["options"]["theme"] = "red";
					 }

					 
					 
					 $timeMapObj[] = $actContext;
				}
				unset($workingContexts);
				
				
				
				
				
				
		  }
		  
		  return $timeMapObj;
	 }
	 
	 
	 
	 function TMassignSize($itemSize, $maxContextCount){
		  $actSize = self::TMmaxSize;
		  $keepLooking = true;
		  $propFactor = .1;
		  $checkSize = $maxContextCount;
		  while(($actSize > 0) && $keepLooking ){
				$checkSize = $checkSize * $actSize * .1;
				if($itemSize >= $checkSize){
					 $keepLooking = false;
					 break;
				}
				else{
					 $actSize = $actSize - 1;
				}
		  }
		  
		  if($actSize < 1){
				$actSize = 1;
		  }
		  
		  return $actSize;
	 }
	 
	 
	 
	 
	 //checks if an array key exists, and if it returns an array
	 function keyArrayCheck($key, $arrayItem){
		  $output = false;
		  if(is_array($arrayItem)){
				if(array_key_exists($key, $arrayItem)){
					 if(is_array($arrayItem[$key])){
						  $output = true;
					 }
				}
		  }
		  return $output;
	 }
	 
	 
	 
	 
    //get list of projects from database
    function DBgetProjects(){
        $this->projectList = false;
        $db_params = OpenContext_OCConfig::get_db_config();
        $db = new Zend_Db_Adapter_Pdo_Mysql($db_params);
		  $db->getConnection();
		  $this->setUTFconnection($db);
	
        $sql = "SELECT projects.project_id 
                FROM projects
                WHERE projects.project_id != '0'
                AND projects.project_id != '2'
					 ORDER BY projects.accession DESC
                ";
		
        $result = $db->fetchAll($sql, 2);
        if($result){
				$this->projectList = $result;
            return $result;
		  }
		  else{
				return false;
		  }
	 }
	 
	 
	 //get project JSON, either from the project conroller or from the cache
	 function projectsJSON($clearCache = false){
		  
		  $this->projectsJSON = false;
		  if(is_array($this->projectList)){
				$projectsJSON = array();
				$host = OpenContext_OCConfig::get_host_config();
				$cache = Zend_Cache::factory('Core',
                             'File',
                             $this->frontendOptions,
                             $this->backendOptions);
				
				foreach($this->projectList as $record){
					 $projectUUID = $record["project_id"];
					 $projJSON = $this->get_cache_json($projectUUID);
					 if($projJSON != false){
						  $projectsJSON[] = $projJSON;
					 }
				}
		  }
	 
		  $this->projectsJSON = $projectsJSON;
		  return $projectsJSON;
	 }
	 
	 
	 function get_cache_json($projectUUID){
		  $projJSON = false;
		  $host = OpenContext_OCConfig::get_host_config();
		  $cache = Zend_Cache::factory('Core',
					   'File',
					   $this->frontendOptions,
					   $this->backendOptions);
		  $cacheID = "pTM_".md5($projectUUID);
		  if(!$cache_result = $cache->load($cacheID)) {
			   @$projJSON_string = file_get_contents($host."/projects/".$projectUUID.".json");
			   if($projJSON_string != false){
					 @$projJSON = Zend_Json::decode($projJSON_string);
					 if(is_array($projJSON)){
						  $cache->save($projJSON, $cacheID ); //save result to the cache, only if valid JSON
					 }
			   }
		  }
		  else{
			   $projJSON = $cache_result;
		  }
		  return $projJSON;
	 }
	 
	 
   
    
    function security_check($input){
        $badArray = array("DROP", "SELECT", "#", "--", "DELETE", "INSERT", "UPDATE", "ALTER", "=");
        foreach($badArray as $bad_word){
            if(stristr($input, $bad_word) != false){
                $input = str_ireplace($bad_word, "XXXXXX", $input);
            }
        }
        return $input;
    }
    
    private function setUTFconnection($db){
	    $sql = "SET collation_connection = utf8_general_ci;";
	    $db->query($sql, 2);
	    $sql = "SET NAMES utf8;";
	    $db->query($sql, 2);
    } 
    
    
    
    
}
