require(jsonlite)
require(xml2)

setwd('C:\\') #set desired working directory where output file should be written

app_id = '1095623181' #This is Rio 2016 Olympic Games app id but change it to your desired app id

#page_num = 1

extract_reviews <- function(app_id,page_num){
  

#building_url

#this extracts all reviews from UK (Great Britain) for other countries replace 'gb' in the below urls with desired country code eg: 'us' or 'in'

json_url <- paste0('http://itunes.apple.com/gb/rss/customerreviews/page=',page_num,'/id=',app_id,'/sortby=mostrecent/','json')
  
xml_url <- paste0('http://itunes.apple.com/gb/rss/customerreviews/page=',page_num,'/id=',app_id,'/sortby=mostrecent/','xml')


#json_url <- 'http://itunes.apple.com/gb/rss/customerreviews/id=370901726/sortBy=mostRecent/json'

js <- fromJSON(json_url)

#extracting selected columns from json 

reviews <- cbind(Title = js$feed$entry$title$label,Author_URL = js$feed$entry$author$uri,Author_Name = js$feed$entry$author$name,App_Version = js$feed$entry$`im:version`$label,Rating = js$feed$entry$`im:rating`$label,Review = js$feed$entry$content$label)

reviews <- reviews[-1,]

names(reviews) <- c('Title','Author_URL','Author_Name','App_Version','Rating','Review')

#reading xml for date

#xml_url <- 'http://itunes.apple.com/gb/rss/customerreviews/id=370901726/sortBy=mostRecent/xml'

xml_n <- read_xml(xml_url)


entries <- xml_children(xml_n)[xml_name(xml_children(xml_n))=='entry']

entries <- entries[-1]

#extrcting date from entries 

date <- xml_text(xml_children(entries))[xml_name(xml_children(entries))=='updated']

reviews$Date <- date

return(reviews)

}

#extracting reviews for 4 pages where one page gives 50 reviews

reviews1 <- extract_reviews(app_id,1)
reviews2 <- extract_reviews(app_id,2)
reviews3 <- extract_reviews(app_id,3)
reviews4 <- extract_reviews(app_id,4)

#combining all the reviews

reviews <- rbind(reviews1,reviews2,reviews3,reviews4)

#re-arraning column order

reviews <- reviews[,c(7,4,5,1,6,3,2)]

#creating output file name based on todays date

op_name <- paste0('reviews_',Sys.Date(),'.csv')

#writing the final csv file 
  
write.csv(reviews,op_name,row.names = F)

