trigger Set_GH_Product_Name on GH_Product__c (before insert, before update) {
    
    Integer PRODUCT_NAME_LEN = 80;
    List<Id> lines_ids = new List<Id>();
    List<String> product_sizes = new List<String>();
    // Trigger.new contains the new Product records
    for (GH_Product__c prod : Trigger.new) {
        // Order of entries in lines_ids and product_sizes follows Trigger.new
        lines_ids.add(prod.Product_Line__c);
        product_sizes.add(prod.Product_Size__c);
    }
    
    // Collect the Product Line masters for the Product detail records    
    List<GH_Product_Line__c> lines = new List<GH_Product_Line__c>();
    lines = [SELECT Id, Name FROM GH_Product_Line__c where Id IN:lines_ids];
    
    // Order of Product_Lines returned by SELECT is indeterminate
    // so a Map is required to recover corresponding data for Id 
    Map<Id, String> id_line_map = new Map<Id, String>();
    for (GH_Product_Line__c line : lines) {
        id_line_map.put(line.Id, line.Name);
    }
    
    //System.debug('Trigger.new' + Trigger.new);
    //System.debug(lines);
    //System.debug(lines_ids);
    //System.debug(product_sizes);
    
    for (GH_Product__c prod : Trigger.new) {
        String product_size = product_sizes.get(0).trim();
        product_sizes.remove(0);
        //    System.debug('product_size ' + product_size);
        Id line_id = lines_ids.get(0);
        lines_ids.remove(0);
        //    System.debug('line id ' + line_id);
        String line_name = id_line_map.get(line_id).trim();
        //    System.debug('line_name ' + line_name);
        String full_prod_name =
            line_name.abbreviate(PRODUCT_NAME_LEN - product_size.length() - 1)
            + ' ' + product_size;
        //    System.debug('full_prod_name ' + full_prod_name);
        
        String existing_prod_name = prod.Name;
        if (existing_prod_name != full_prod_name) {
            //System.debug('Product name change: '
             //+ existing_prod_name + ' -> ' + full_prod_name);
            prod.Name = full_prod_name;
        }
    }    
    
}