-- 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. ( npi 1881634483  99707)

SELECT *
FROM prescription;

SELECT *
FROM prescriber;

SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;



-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
(BRUCE PENDLEY - FAMILY PRACTICE

SELECT npi, SUM(total_claim_count) AS total_claims, prescriber.nppes_provider_first_name AS first_name, prescriber.nppes_provider_last_org_name AS last_name, prescriber.specialty_description AS specialty
FROM prescription
INNER JOIN prescriber
USING (npi)
GROUP BY npi, first_name, last_name, specialty
ORDER BY total_claims DESC;
 
 
 
 
--  2   a. Which specialty had the most total number of claims (totaled over all drugs)?  (Nurse Practitioner)
 
 SELECT prescriber.specialty_description AS specialty, SUM(total_claim_count) AS total_claims
 FROM prescriber
 INNER JOIN prescription
 USING (npi)
 GROUP BY specialty 
 ORDER BY total_claims DESC;

-- b. Which specialty had the most total number of claims for opioids?

SELECT drug.opioid_drug_flag AS opioid, prescriber.specialty_description AS specialty, SUM(total_claim_count) AS total_claims
 FROM drug
 INNER JOIN prescription
 USING(drug_name)
 INNER JOIN prescriber
 ON prescription.npi = prescriber.npi
 WHERE opioid_drug_flag = 'Y'
 GROUP BY opioid, specialty
 ORDER BY total_claims DESC;
 
 
-- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT DISTINCT specialty_description
FROM prescriber
WHERE specialty_description NOT IN(SELECT specialty_description
							       FROM prescription
								   INNER JOIN prescriber
								   USING (npi));




--  d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? 
 
SELECT DISTINCT specialty_description,COUNT(total_claim_count)*100/SUM(COUNT(total_claim_count)) OVER() percentage_claim 
FROM prescriber
INNER JOIN prescription
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
 
 
--  3   a. Which drug (generic_name) had the highest total drug cost? (INSULIN GLARGINE   $104,264,066.35)
 
 
SELECT SUM(total_drug_cost::money) AS highest_cost, drug.generic_name
 FROM prescription
 INNER JOIN drug
 USING (drug_name)
 GROUP BY drug.generic_name
 ORDER BY highest_cost DESC; 
 
 
 -- b. Which drug (generic_name) has the hightest total cost per day? (C1 ESTERASE INHIBITOR -$3,495.22)
 
 SELECT (SUM(total_drug_cost)/SUM(total_day_supply))::money AS daily_cost, drug.generic_name
 FROM prescription 
 INNER JOIN drug
 USING (drug_name)
 GROUP BY drug.generic_name
 ORDER BY daily_cost DESC;
 
 
--   4.   a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
 (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
       ELSE 'neither' END) AS drug_type
FROM drug 

 
-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision. 
--  (SPENT MORE ON OPIOID )

SELECT (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
       ELSE 'neither' END) AS drug_type, SUM (total_drug_cost)::money AS total_cost
FROM drug
INNER JOIN prescription USING (drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

 
 
--  5.a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee. (56)
 
 SELECT COUNT(DISTINCT cbsaname)
 FROM cbsa
 WHERE cbsaname LIKE '%TN%'
 
 
-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population. CBSANAME - (NASHVILLE_DAVIDSON_MURFR_FRKLN, TN -1830410) largest
--                        (MORRISTOWN, TN-116352) smallest
 SELECT SUM (population) AS total_population, cbsa, cbsaname
 FROM cbsa
 INNER JOIN population
 USING (fipscounty)
 GROUP BY cbsa, cbsaname
 ORDER BY total_population DESC;
 
 
--c . What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population. 
 
SELECT population, county
FROM population
INNER JOIN fips_county
USING (fipscounty)
FULL JOIN cbsa
USING (fipscounty)
WHERE cbsa IS NULL AND fips_county IS NOT NULL
ORDER BY population DESC;

 
-- 6 a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
 
 SELECT total_claim_count, drug_name
 FROM prescription 
 WHERE total_claim_count >= 3000


 
--  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
 SELECT *
 FROM prescription
 
 
 SELECT  drug_name, total_claim_count,
   (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    ELSE 'not opioid' END) AS drug_type
 FROM prescription
 INNER JOIN drug
 USING (drug_name)
 WHERE total_claim_count >= 3000
 ORDER BY total_claim_count DESC 
 
 
 
--  c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
 
  SELECT  drug_name, total_claim_count, nppes_provider_last_org_name AS prescriber_last_name, nppes_provider_first_name AS prescriber_first_name,
  (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    ELSE 'not opioid' END) AS drug_type
 FROM prescription
 INNER JOIN drug
 USING (drug_name)
 INNER JOIN prescriber
 USING (npi)
 WHERE total_claim_count >= 3000
 ORDER BY total_claim_count DESC 
 
 
 
 
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
 
 
SELECT npi, drug_name, specialty_description, nppes_provider_city
FROM drug
CROSS JOIN prescriber
WHERE specialty_description ='Pain Management' AND opioid_drug_flag = 'Y' AND 
      nppes_provider_city = 'NASHVILLE'

 
 
--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count). 
 

SELECT npi, drug_name, total_claim_count
FROM drug
CROSS JOIN prescriber
LEFT JOIN prescription
USING (npi,drug_name)
WHERE specialty_description ='Pain Management' AND opioid_drug_flag = 'Y' AND 
      nppes_provider_city = 'NASHVILLE' 
 
 
 
--  c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function
 
SELECT npi, drug_name, 
            COALESCE(total_claim_count,0) AS total_claims
FROM drug
CROSS JOIN prescriber
LEFT JOIN prescription
USING (npi,drug_name)
WHERE specialty_description ='Pain Management' AND opioid_drug_flag = 'Y' AND 
      nppes_provider_city = 'NASHVILLE' 

 
 
 
BONUS QUESTIONS:

-- 1. How many npi numbers appear in the prescriber table but not in the prescription table? 

(SELECT npi
FROM prescriber)
EXCEPT
(SELECT npi
FROM prescription)
 
 
 
--  2. a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

-- SELECT DISTINCT generic_name, total_claim_count
-- FROM drug
-- INNER JOIN prescription
-- USING (drug_name)
-- INNER JOIN prescriber
-- USING (npi)
-- WHERE specialty_description = 'Family Practice'
-- ORDER BY total_claim_count DESC
-- LIMIT 5;

SELECT generic_name, SUM(total_claim_count) AS total_count
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY drug.generic_name
ORDER BY total_count DESC
LIMIT 5;

 
 
-- b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology. 

SELECT DISTINCT drug.generic_name, SUM(total_claim_count) AS all_drugs
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description ILIKE '%Cardiology%'
GROUP BY drug.generic_name
ORDER BY all_drugs DESC
LIMIT 5; 
 


-- c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
 
SELECT DISTINCT drug.generic_name, specialty_description, SUM(total_claim_count) AS all_drugs
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi) 
WHERE   specialty_description ILIKE '%Cardiology%' OR specialty_description = 'Family Practice'
GROUP BY drug.generic_name, specialty_description
ORDER BY all_drugs DESC
LIMIT 5;
 
 
-- OR ---
 
 
(SELECT generic_name, SUM(total_claim_count) AS total_count
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY drug.generic_name
ORDER BY total_count DESC
LIMIT 5)
UNION ALL
(SELECT DISTINCT drug.generic_name, SUM(total_claim_count) AS all_drugs
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description ILIKE '%Cardiology%'
GROUP BY drug.generic_name
ORDER BY all_drugs DESC
LIMIT 5);
 
-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

SELECT npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP by npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5;
 
 
 
-- b.Now, report the same for Memphis 
 
SELECT npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP by npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5;
  

 
--  c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

SELECT npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS' OR nppes_provider_city = 'NASHVILLE' OR nppes_provider_city = 'KNOXVILLE' OR nppes_provider_city = 'CHATTANOOGA'
GROUP by npi, provider_last_name, provider_city
ORDER BY all_count DESC

--     OR -------
 
(SELECT prescription.npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP by npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5)
UNION ALL
(SELECT prescription.npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP by prescription.npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5)
UNION ALL 
(SELECT prescription.npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP by npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5)
UNION ALL
(SELECT prescription.npi, SUM (total_claim_count) AS all_count, nppes_provider_last_org_name AS provider_last_name, nppes_provider_city AS provider_city
FROM prescription
INNER JOIN prescriber 
USING (npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP by prescription.npi, provider_last_name, provider_city
ORDER BY all_count DESC
LIMIT 5)
 



 
--  4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT county, SUM(overdose_deaths) AS total_deaths
FROM overdose_deaths
INNER JOIN fips_county
ON overdose_deaths.fipscounty = fips_county.fipscounty::integer
WHERE overdose_deaths >(SELECT AVG(overdose_deaths) FROM overdose_deaths)
GROUP BY county
ORDER BY total_deaths DESC; 
 
-- SELECT * 
-- FROM fips_county
 
-- SELECT *
-- FROM overdose_deaths
 
 
-- 5. a. Write a query that finds the total population of Tennessee
 
SELECT state, SUM(population) AS total_population
FROM population
INNER JOIN fips_county
USING (fipscounty)
GROUP BY state

 
-- b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county. 
 
SELECT county, state,(SUM(population)/(SELECT SUM(population) AS total_population
											  FROM population
                                             INNER JOIN fips_county
                                             USING (fipscounty)
                                              GROUP BY state)*100) AS percentage_pop
FROM population
                                        
INNER JOIN fips_county
USING (fipscounty)
GROUP BY state, county
ORDER BY percentage_pop DESC;

