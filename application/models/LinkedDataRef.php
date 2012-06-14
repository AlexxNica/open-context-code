<?php


//this class looks up linked data references, to produce human readable versions
class LinkedDataRef{
    
    public $refURI; //request URI
    public $refLabel; // array of the request parameters and values
    public $refVocabulary;
    public $refVocabURI;
       
    //add raw solr facet results, set aside time spans for special treatment
    function lookup_refURI($refURI){
		$db_params = OpenContext_OCConfig::get_db_config();
        $db = new Zend_Db_Adapter_Pdo_Mysql($db_params);
		$db->getConnection();
        
		$refURI = $this->security_check($refURI);
		$this->refURI = $refURI;
	
		//echo chr(13).chr(13).$refURI;
	
        $sql = 'SELECT *
                FROM linked_data
                WHERE linkedURI LIKE "'.$refURI.'"
                LIMIT 1';
		
        $result = $db->fetchAll($sql, 2);
		$db->closeConnection();
        if($result){
	
			$this->refLabel = $result[0]["linkedLabel"];
			$this->refVocabulary = $result[0]["vocabulary"];
			$this->refVocabURI = $result[0]["vocabURI"];
		
			return true;
		}
		else{
			$this->refLabel = false;
			$this->refVocabulary = false;
			$this->refVocabURIy = false;
			return false;
		}
    }//end function


	//this is used for entity reconciliation
	public function lookupVarNamesByRelURI($refURI){
		$db_params = OpenContext_OCConfig::get_db_config();
        $db = new Zend_Db_Adapter_Pdo_Mysql($db_params);
		$db->getConnection();
        
		$refURI = $this->security_check($refURI);
		$this->refURI = $refURI;
	
		//echo chr(13).chr(13).$refURI;
	
        $sql = 'SELECT DISTINCT var_tab.var_label
                FROM linked_data
				JOIN var_tab ON var_tab.variable_uuid = linked_data.itemUUID
                WHERE linkedURI LIKE "'.$refURI.'"
                ';
		
        $result = $db->fetchAll($sql, 2);
		$db->closeConnection();
        if($result){
	
			$combined = array();
			foreach($result as $row){
				$combined[] = $row["var_label"];
			}
			
			return implode("||", $combined);
			
		}
		else{
			
			return false;
		}
	}




    function security_check($input){
        $badArray = array("DROP", "SELECT", "--", "DELETE", "INSERT", "UPDATE", "ALTER", "=");
        foreach($badArray as $bad_word){
            if(stristr($input, $bad_word) != false){
                $input = str_ireplace($bad_word, "XXXXXX", $input);
            }
        }
        return $input;
    }

}