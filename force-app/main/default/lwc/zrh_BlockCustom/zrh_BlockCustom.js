/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 27/03/2023
Description  : Javascript - Omniscript Block Custom
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Mateo Long                        ML
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       ML	     27/03/2023		  initial version
********************************************************************************/
import omniscriptBlock from "vlocity_ins/omniscriptBlock";
import template from "./zrh_BlockCustom.html"
export default class zrh_BlockCustom extends omniscriptBlock {
    // your properties and methods here

    render()
    {
        return template;
    }
}