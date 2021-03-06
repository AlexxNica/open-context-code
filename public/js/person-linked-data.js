var loaderImage = "../images/layout/ajax-loader.gif";
var DOIresolver = "http://dx.doi.org/";
var linkDomID = 0;
var linkDataDivID = "";

function getLinks(){
    
    var personLinksDiv = document.getElementById("person-links");
    if(personLinksDiv !== null ){
        var rows = document.getElementsByClassName("person-link");
        for(i=0; i < rows.length; i++){
            linkDomID = i + 1;  //xslt starts indices as 1, not 0
            var link = rows[i].href ;
            if(link.indexOf("http://orcid.org") >= 0){
                //we have an ORCID identifier!
                linkDataDivID = "plink-data-" + linkDomID;
                var linkDataDiv = document.getElementById(linkDataDivID);
                addWaitingMessage(linkDataDiv);
                orcidRecord(link);
            }
        }
        //orcidRecord(orcidURI);
    }
}

function addWaitingMessage(domNode){
    var message = "<br/>Loading linked data...";
    message += "<br/>";
    message += "<img src=\"" + loaderImage + "\" alt=\"Loading...\" />";
    domNode.innerHTML = message;
}


function orcidRecord(orcidURI){
    
    Ajax.Request.prototype.respondToReadyState_orig =
    Ajax.Request.prototype.respondToReadyState;
    Ajax.Request.prototype.respondToReadyState = function(readyState) {
    // Catch the exception, if there is one.
    try {
      this.respondToReadyState_orig(readyState);
    }
    catch(e) {
      this.dispatchException(e);
      var linkDataDiv = document.getElementById(linkDataDivID);
      linkDataDiv.innerHTML = "Your browser cannot display ORCID data now. Please check link above, or try this with Chrome, Firefox, Opera, or Safari.";
    }
    };
    
    
    var requestURI = orcidWidget;
    var myAjax = new Ajax.Request(requestURI,
        {method: 'get',
        parameters:
        {
            uri: orcidURI
        },
        onComplete: orcidRecordDone }
    );

}
    
function orcidRecordDone(response){
    var linkDataDiv = document.getElementById(linkDataDivID);
    var success = false;
    try
    {
        var respData = JSON.parse(response.responseText);
        success = true;
    }
    catch(e){
        linkDataDiv.innerHTML = "Your browser cannot display ORCID data now. Please check link above, or try this with Chrome, Firefox, Opera, or Safari.";
    }
    
    if(success){
        linkDataDiv.innerHTML = "";
        if(respData.hasOwnProperty("error-desc")){
            linkDataDiv.innerHTML = "Cannot display ORCID data now. Please check link above.";
        }
        else{
            orcidOK(respData, linkDataDiv);
        }
    }
    
}

 function orcidOK(respData, linkDataDiv){
    var orcidBio = respData["orcid-profile"]["orcid-bio"];
    var orcidAct = respData["orcid-profile"]["orcid-activities"];
    
    var orcidNameDom = document.createElement("p");
    var orcidName = "<b>Given name:</b> " + orcidBio["personal-details"]["given-names"]["value"] + " <b>Family name:</b> " + orcidBio["personal-details"]["family-name"]["value"];
    orcidNameDom.innerHTML = orcidName;
    linkDataDiv.appendChild(orcidNameDom);

    if(orcidBio["researcher-urls"] !== null && orcidBio["researcher-urls"] !== undefined){
        
        if(orcidBio["researcher-urls"]["researcher-url"].length > 0){
             
            var linkListHeadDom = document.createElement("h6");
            var linkListHead = "Related Links";
            linkListHeadDom.innerHTML = linkListHead;
            linkDataDiv.appendChild(linkListHeadDom);
            
            var linkList = document.createElement("ul");
            linkDataDiv.appendChild(linkList);
            
            for(i=0; i < orcidBio["researcher-urls"]["researcher-url"].length; i++){
                var bioURL = orcidBio["researcher-urls"]["researcher-url"][i];
                var listItem = document.createElement("li");
                var listLink = document.createElement("a");
                listLink.setAttribute("href", bioURL["url"]["value"]);
                if(bioURL["url-name"]["value"].length > 1){
                    listLink.innerHTML = bioURL["url-name"]["value"];
                }
                else{
                    listLink.innerHTML = bioURL["url"]["value"];
                }
                listItem.appendChild(listLink);
                linkList.appendChild(listItem);
            }
        }
    }
   
    if(orcidBio["keywords"] !== null && orcidBio["keywords"] !== undefined){
        if(orcidBio["keywords"]["keyword"].length > 0){
            
            var kwHeadDom = document.createElement("h6");
            var kwHead = "Interest Keywords";
            kwHeadDom.innerHTML = kwHead;
            linkDataDiv.appendChild(kwHeadDom);
            
            var kwListDom = document.createElement("p");
            var keywords = "";
            
            for(i=0; i < orcidBio["keywords"]["keyword"].length; i++){
                var keyword = orcidBio["keywords"]["keyword"][i]["value"];
                if(i > 0){
                    keywords += ", <em>" + keyword + "</em>";
                }
                else{
                    keywords = "<em>" + keyword + "</em>";
                }
            }
            kwListDom.innerHTML = keywords;
            linkDataDiv.appendChild(kwListDom);
        }
    }

    if(orcidBio["biography"] !== null && orcidBio["biography"] !== undefined){
        if(orcidBio["biography"]["value"].length > 0){
            var biographyHeadDom = document.createElement("h6");
            var biographyHead = "Biography";
            biographyHeadDom.innerHTML = biographyHead ;
            linkDataDiv.appendChild(biographyHeadDom);
            
            var biographyDom = document.createElement("p");
            biographyDom.setAttribute("id", "orcid-bio");
            biographyDom.setAttribute("style", "white-space:pre-line;");
            var biography = orcidBio["biography"]["value"];
            biography.replace(/\r\n|\r|\n/g, '<br />');
            biographyDom.innerHTML = biography;
            linkDataDiv.appendChild(biographyDom);
        }
    }
    
    if(orcidAct["orcid-works"] !== null){
        
        if(orcidAct["orcid-works"]["orcid-work"].length > 0){
            var pubHeadDom = document.createElement("h6");
            var pubHead = "Selected Publications";
            pubHeadDom.innerHTML = pubHead;
            linkDataDiv.appendChild(pubHeadDom);
            
            var pubList = document.createElement("ul");
            pubList.setAttribute("class", "orcid-pubs");
            linkDataDiv.appendChild(pubList);
            
            for(i=0; i < orcidAct["orcid-works"]["orcid-work"].length; i++){
                var pubObj = orcidAct["orcid-works"]["orcid-work"][i];
                
                //make a url from the publication, either by getting the listed url or making one from a DOI
                var pubURL = false;
                
                if(pubObj["url"] !== null){
                    if(pubObj["url"]["value"] !== null){
                        pubURL = pubObj["url"]["value"];
                    }
                }
                else{
                    if(pubObj["work-external-identifiers"] != null){
                        
                        if(pubObj["work-external-identifiers"]["work-external-identifier"].length >0){
                            for(jj=0; jj < pubObj["work-external-identifiers"]["work-external-identifier"].length; jj++){
                                
                                //alert("loop" + jj + " on " + i);
                                
                                var pubID = pubObj["work-external-identifiers"]["work-external-identifier"][jj];
                                if(pubID["work-external-identifier-type"] == "DOI"){
                                    pubURL = DOIresolver + pubID["work-external-identifier-id"]["value"];
                                }
                            }
                        }
                    }
                }
                
                var pubTitle = "(Title not provided)";
                if(pubObj["work-title"] !== null){
                    pubTitle = pubObj["work-title"]["title"]["value"];
                }
                if(pubURL !== false){
                    pubTitle = "<a href=\"" + pubURL + "\">" + pubTitle + "</a>";
                }
                else{
                    pubTitle = "<b>" + pubTitle + "</b>";
                }
                
                var pubCitation = "(Citation not provided)";
                if(pubObj["work-citation"] !== null){
                    if(pubObj["work-citation"]["work-citation-type"] != "BIBTEX" ){
                        pubCitation = pubObj["work-citation"]["citation"];
                    }
                    else{
                        pubCitation = "";
                        var b = new BibtexParser();
                        b.setInput(pubObj["work-citation"]["citation"]);
                        b.bibtex();
                        var e = b.getEntries();
                        for (var item in e) {
                            for (var key in e[item]) {
                                
                                
                            }
                            var curItem = e[item];
                            if("AUTHOR" in curItem){
                                pubCitation = curItem["AUTHOR"];
                            }
                            if("YEAR" in curItem){
                                pubCitation += " (" + curItem["YEAR"] + ")";
                            }
                            if("TITLE" in curItem){
                                pubCitation += " " + curItem["TITLE"];
                            }
                            if("JOURNAL" in curItem){
                                pubCitation += " <em>" + curItem["JOURNAL"] + "</em>";
                            }
                            if("PAGES" in curItem){
                                pubCitation += ":" + curItem["PAGES"] + " ";
                            }
                        }
                    }
                }
                
                //alert(pubCitation);
                
                var pubHTML = "<div>" + pubTitle + "<br/>" +  pubCitation + "</div>";
                var pubItem = document.createElement("li");
                pubItem.innerHTML = pubHTML;
                pubList.appendChild(pubItem);
            }
            
            
        }
    }
    
    //alert("here");
}