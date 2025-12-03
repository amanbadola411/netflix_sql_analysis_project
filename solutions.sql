-- Netflix Project

create table netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1000),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
select * from netflix;


select count(*) as total_movies from netflix;

select distinct type from netflix;

select * from netflix
where type='Movie';

-- 15 Business Problems

-- 1. Count the number of movies vs TV shows

select type, count(*) as total_content from netflix
group by type;


-- 2. Find the Most Common Rating for Movies and TV Shows


select type, rating from 
(select type, rating, count(*), rank() over(partition by type order by count(*) desc) as rankings from netflix
group by 1,2) as t1 where rankings=1;


-- 3. List All Movies Released in a Specific Year (e.g., 2020)


select * from netflix where type='Movie' and release_year=2020;


-- 4. Find the Top 5 Countries with the Most Content on Netflix


select unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content from netflix
group by 1
order by 2 desc
limit 5


-- 5. Identify the Longest Movie


select * from netflix
where type='Movie'
and duration = (select max(duration) from netflix)



-- 6. Find Content Added in the Last 5 Years


select * from netflix
where to_date(date_added, 'month dd,yyyy') >= current_date - INTERVAL '5 years'

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'


select * from netflix where director like '%Rajiv Chilaka%'


-- 8. List All TV Shows with More Than 5 Seasons


select *, split_part(duration, ' ', 1) as season from netflix where type='TV Show' and split_part(duration, ' ', 1)::numeric > 5


-- 9. Count the Number of Content Items in Each Genre


select unnest(string_to_array(listed_in, ',')) as genre, count(show_id) as total from netflix group by 1 order by 2 desc


-- 10.Find each year and the average numbers of content release in India on netflix, return top 5 with highest avg content release


select 
	extract(year from to_date(date_added, 'month dd,yyyy')) as dates,
	count(*) as yearly_content,
	round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric * 100 ,
	2) as avg_content_per_year
from netflix where country = 'India'
group by 1


-- 11. List All Movies that are Documentaries


select * from netflix where listed_in Ilike '%Documentaries%'


-- 12. Find All Content Without a Director


select * from netflix where director is null


-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years


select * from netflix
where casts ilike '%Salman Khan%' and release_year > extract(year from current_date)-10


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India


select --show_id, casts, 
unnest(string_to_array(casts, ',')) as actors, count(*) as total_content from netflix
where country ilike '%india%'
group by 1 order by total_content desc
limit 10

/*
 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords 
in the description field. Label content containing these keywords as "bad" and 
all other content as 'good'. Count how may content fall into each category.
*/

with new_table
as
(
select *, 
case 
when description ilike '%kill%' or description ilike '%violence%' 
then 'Bad_Content' else 'Good_Content'
end category
from netflix
)
select category,
count(*) as total_content from new_table
group by 1

 

