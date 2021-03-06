<?php
/** Zend_Controller_Action */
require_once 'Zend/Controller/Action.php';
ini_set("max_execution_time", "0");

class propertiesController extends Zend_Controller_Action
{   
      
    public function indexAction(){
    
    }
    
    
    public function viewAction() {
		
		  $itemUUID = $this->_request->getParam('property_uuid');  

		  $itemObj = new dbXML_dbPropitem;
		  $itemObj->initialize();
		  $db = $itemObj->db;
		  $itemObj->dbPenelope = true;
		  $found = $itemObj->getByID($itemUUID);
		
		  if($found){
				$propsObj = new dbXML_dbProperties;
				$propsObj->initialize($db);
				$propsObj->dbPenelope = true;
				$propsObj->getProperties($itemObj->itemUUID);
				$itemObj->propertiesObj = $propsObj;
				
				$linksObj = new dbXML_dbLinks;
				$linksObj->initialize($db);
				//$linksObj->dbPenelope = true;
				//$linksObj->getLinks($itemObj->itemUUID);
				$itemObj->linksObj = $linksObj;
				
				$metadataObj = new dbXML_dbxmlMetadata;
				$metadataObj->initialize($db);
				$metadataObj->getMetadata($itemObj->projectUUID);
				$itemObj->metadataObj = $metadataObj;
		  
				$itemObj->makeQueryVal();
				$itemObj->solrDBpropertySummary();
			 
				$xmlItem = new dbXML_xmlProperty;
				$xmlItem->itemObj = $itemObj;
				$xmlItem->initialize();
				$xmlItem->addName();
				$xmlItem->addPropDetails();
				$xmlItem->addPropsLinks();
				$xmlItem->addMetadata();
				
				$doc = $xmlItem->doc;
				$xmlString =  $doc->saveXML();
				unset($doc);
				$XML = simplexml_load_string($xmlString);
				$XML = OpenContext_ProjectReviewAnnotate::addProjectReviewStatus($itemObj->projectUUID, $XML, $xmlItem->nameSpaces());
				$xmlString  = $XML->asXML();
				$this->view->xml_string = $xmlString ;
		  }
		  else{
				$this->view->requestURI = $this->_request->getRequestUri(); 
				return $this->render('404error');
		  }
    }
    
	 public function xmlAction() {
		  
		  $this->_helper->viewRenderer->setNoRender();
        // get the property uuid from the uri
		  $itemUUID = $this->_request->getParam('property_uuid');  

		  $itemObj = new dbXML_dbPropitem;
		  $itemObj->initialize();
		  $db = $itemObj->db;
		  $itemObj->dbPenelope = true;
		  $found = $itemObj->getByID($itemUUID);
		
		  if($found){
				$propsObj = new dbXML_dbProperties;
				$propsObj->initialize($db);
				$propsObj->dbPenelope = true;
				$propsObj->getProperties($itemObj->itemUUID);
				$itemObj->propertiesObj = $propsObj;
				
				$linksObj = new dbXML_dbLinks;
				$linksObj->initialize($db);
				//$linksObj->dbPenelope = true;
				//$linksObj->getLinks($itemObj->itemUUID);
				$itemObj->linksObj = $linksObj;
				
				$metadataObj = new dbXML_dbxmlMetadata;
				$metadataObj->initialize($db);
				$metadataObj->getMetadata($itemObj->projectUUID);
				$itemObj->metadataObj = $metadataObj;
		  
				$itemObj->makeQueryVal();
				$itemObj->solrDBpropertySummary();
			 
				$xmlItem = new dbXML_xmlProperty;
				$xmlItem->itemObj = $itemObj;
				$xmlItem->initialize();
				$xmlItem->addName();
				$xmlItem->addPropDetails();
				$xmlItem->addPropsLinks();
				$xmlItem->addMetadata();
				
				$doc = $xmlItem->doc;
				header('Content-Type: application/xml; charset=utf8');
				echo $doc->saveXML();
		  }
		  else{
				$this->view->requestURI = $this->_request->getRequestUri(); 
				return $this->render('404error');
		  }
	 }
	 
	 public function atomAction() {
		  
		  $this->_helper->viewRenderer->setNoRender();
		  echo "atom";
	 }
    
	 public function jsonAction() {
		  
		  $this->_helper->viewRenderer->setNoRender();
		  $this->_helper->viewRenderer->setNoRender();
        // get the property uuid from the uri
		  $itemUUID = $this->_request->getParam('property_uuid');  

		  $itemObj = new dbXML_dbPropitem;
		  $itemObj->initialize();
		  $db = $itemObj->db;
		  $itemObj->dbPenelope = true;
		  $itemObj->getByID($itemUUID);
	 
	 
		  $propsObj = new dbXML_dbProperties;
		  $propsObj->initialize($db);
		  $propsObj->dbPenelope = true;
		  $propsObj->getProperties($itemObj->itemUUID);
		  $itemObj->propertiesObj = $propsObj;
	  
		  $linksObj = new dbXML_dbLinks;
		  $linksObj->initialize($db);
		  //$linksObj->dbPenelope = true;
		  //$linksObj->getLinks($itemObj->itemUUID);
		  $itemObj->linksObj = $linksObj;
 	 
		  $metadataObj = new dbXML_dbxmlMetadata;
		  $metadataObj->initialize($db);
		  $metadataObj->getMetadata($itemObj->projectUUID);
		  $itemObj->metadataObj = $metadataObj;
		  
		  $itemObj->makeQueryVal();
	 
		  $itemObj->solrDBpropertySummary();
	 
		  header('Content-Type: application/json; charset=utf8');
		  echo Zend_Json::encode($itemObj);
	 }
    
}

