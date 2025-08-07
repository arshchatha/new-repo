const Map<String, Map<String, List<String>>> locationData = {
  'United States': {
    'Alabama': [
      'Alexander City', 'Andalusia', 'Anniston', 'Athens', 'Atmore', 'Auburn', 'Bessemer', 'Birmingham', 'Chickasaw', 'Clanton',
      'Cullman', 'Decatur', 'Demopolis', 'Dothan', 'Enterprise', 'Eufaula', 'Florence', 'Fort Payne', 'Gadsden', 'Greenville',
      'Guntersville', 'Huntsville', 'Jasper', 'Marion', 'Mobile', 'Montgomery', 'Opelika', 'Ozark', 'Phenix City', 'Prichard',
      'Scottsboro', 'Selma', 'Sheffield', 'Sylacauga', 'Talladega', 'Troy', 'Tuscaloosa', 'Tuscumbia', 'Tuskegee'
    ],
    'Alaska': [
      'Anchorage', 'Cordova', 'Fairbanks', 'Haines', 'Homer', 'Juneau', 'Ketchikan', 'Kodiak', 'Kotzebue', 'Nome',
      'Palmer', 'Seward', 'Sitka', 'Skagway', 'Valdez'
    ],
    'Arizona': [
      'Ajo', 'Avondale', 'Bisbee', 'Casa Grande', 'Chandler', 'Clifton', 'Douglas', 'Flagstaff', 'Florence', 'Gila Bend',
      'Glendale', 'Globe', 'Kingman', 'Lake Havasu City', 'Mesa', 'Nogales', 'Oraibi', 'Phoenix', 'Prescott', 'Scottsdale',
      'Sierra Vista', 'Tempe', 'Tombstone', 'Tucson', 'Walpi', 'Window Rock', 'Winslow', 'Yuma'
    ],
    'Arkansas': [
      'Arkadelphia', 'Arkansas Post', 'Batesville', 'Benton', 'Blytheville', 'Camden', 'Conway', 'Crossett', 'El Dorado', 'Fayetteville',
      'Forrest City', 'Fort Smith', 'Harrison', 'Helena', 'Hope', 'Hot Springs', 'Jacksonville', 'Jonesboro', 'Little Rock', 'Magnolia',
      'Morrilton', 'Newport', 'North Little Rock', 'Osceola', 'Pine Bluff', 'Rogers', 'Searcy', 'Stuttgart', 'Van Buren', 'West Memphis'
    ],
    'California': [
      'Alameda', 'Alhambra', 'Anaheim', 'Antioch', 'Arcadia', 'Bakersfield', 'Barstow', 'Belmont', 'Berkeley', 'Beverly Hills',
      'Brea', 'Buena Park', 'Burbank', 'Calexico', 'Calistoga', 'Carlsbad', 'Carmel', 'Chico', 'Chula Vista', 'Claremont',
      'Compton', 'Concord', 'Corona', 'Coronado', 'Costa Mesa', 'Culver City', 'Daly City', 'Davis', 'Downey', 'El Centro',
      'El Cerrito', 'El Monte', 'Escondido', 'Eureka', 'Fairfield', 'Fontana', 'Fremont', 'Fresno', 'Fullerton', 'Garden Grove',
      'Glendale', 'Hayward', 'Hollywood', 'Huntington Beach', 'Indio', 'Inglewood', 'Irvine', 'La Habra', 'Laguna Beach', 'Lancaster',
      'Livermore', 'Lodi', 'Lompoc', 'Long Beach', 'Los Angeles', 'Malibu', 'Martinez', 'Marysville', 'Menlo Park', 'Merced',
      'Modesto', 'Monterey', 'Mountain View', 'Napa', 'Needles', 'Newport Beach', 'Norwalk', 'Novato', 'Oakland', 'Oceanside',
      'Ojai', 'Ontario', 'Orange', 'Oroville', 'Oxnard', 'Pacific Grove', 'Palm Springs', 'Palmdale', 'Palo Alto', 'Pasadena',
      'Petaluma', 'Pomona', 'Port Hueneme', 'Rancho Cucamonga', 'Red Bluff', 'Redding', 'Redlands', 'Redondo Beach', 'Redwood City', 'Richmond',
      'Riverside', 'Roseville', 'Sacramento', 'Salinas', 'San Bernardino', 'San Clemente', 'San Diego', 'San Fernando', 'San Francisco', 'San Gabriel',
      'San Jose', 'San Juan Capistrano', 'San Leandro', 'San Luis Obispo', 'San Marino', 'San Mateo', 'San Pedro', 'San Rafael', 'San Simeon', 'Santa Ana',
      'Santa Barbara', 'Santa Clara', 'Santa Clarita', 'Santa Cruz', 'Santa Monica', 'Santa Rosa', 'Sausalito', 'Simi Valley', 'Sonoma', 'South San Francisco',
      'Stockton', 'Sunnyvale', 'Susanville', 'Thousand Oaks', 'Torrance', 'Turlock', 'Ukiah', 'Vallejo', 'Ventura', 'Victorville',
      'Visalia', 'Walnut Creek', 'Watts', 'West Covina', 'Whittier', 'Woodland', 'Yorba Linda', 'Yuba City'
    ],
    'Colorado': [
      'Alamosa', 'Aspen', 'Aurora', 'Boulder', 'Breckenridge', 'Brighton', 'Canon City', 'Central City', 'Climax', 'Colorado Springs',
      'Cortez', 'Cripple Creek', 'Denver', 'Durango', 'Englewood', 'Estes Park', 'Fort Collins', 'Fort Morgan', 'Georgetown', 'Glenwood Springs',
      'Golden', 'Grand Junction', 'Greeley', 'Gunnison', 'La Junta', 'Leadville', 'Littleton', 'Longmont', 'Loveland', 'Montrose',
      'Ouray', 'Pagosa Springs', 'Pueblo', 'Silverton', 'Steamboat Springs', 'Sterling', 'Telluride', 'Trinidad', 'Vail', 'Walsenburg', 'Westminster'
    ],
    'Connecticut': [
      'Ansonia', 'Berlin', 'Bloomfield', 'Branford', 'Bridgeport', 'Bristol', 'Coventry', 'Danbury', 'Darien', 'Derby',
      'East Hartford', 'East Haven', 'Enfield', 'Fairfield', 'Farmington', 'Greenwich', 'Groton', 'Guilford', 'Hamden', 'Hartford',
      'Lebanon', 'Litchfield', 'Manchester', 'Mansfield', 'Meriden', 'Middletown', 'Milford', 'Mystic', 'Naugatuck', 'New Britain',
      'New Haven', 'New London', 'North Haven', 'Norwalk', 'Norwich', 'Old Saybrook', 'Orange', 'Seymour', 'Shelton', 'Simsbury',
      'Southington', 'Stamford', 'Stonington', 'Stratford', 'Torrington', 'Wallingford', 'Waterbury', 'Waterford', 'Watertown', 'West Hartford',
      'West Haven', 'Westport', 'Wethersfield', 'Willimantic', 'Windham', 'Windsor', 'Windsor Locks', 'Winsted'
    ],
    'Delaware': [
      'Dover', 'Lewes', 'Milford', 'New Castle', 'Newark', 'Smyrna', 'Wilmington'
    ],
    'Florida': [
      'Apalachicola', 'Bartow', 'Belle Glade', 'Boca Raton', 'Bradenton', 'Cape Coral', 'Clearwater', 'Cocoa Beach', 'Cocoa-Rockledge', 'Coral Gables',
      'Daytona Beach', 'De Land', 'Deerfield Beach', 'Delray Beach', 'Fernandina Beach', 'Fort Lauderdale', 'Fort Myers', 'Fort Pierce', 'Fort Walton Beach', 'Gainesville',
      'Hallandale Beach', 'Hialeah', 'Hollywood', 'Homestead', 'Jacksonville', 'Key West', 'Lake City', 'Lake Wales', 'Lakeland', 'Largo',
      'Melbourne', 'Miami', 'Miami Beach', 'Naples', 'New Smyrna Beach', 'Ocala', 'Orlando', 'Ormond Beach', 'Palatka', 'Palm Bay',
      'Palm Beach', 'Panama City', 'Pensacola', 'Pompano Beach', 'Saint Augustine', 'Saint Petersburg', 'Sanford', 'Sarasota', 'Sebring', 'Tallahassee',
      'Tampa', 'Tarpon Springs', 'Titusville', 'Venice', 'West Palm Beach', 'White Springs', 'Winter Haven', 'Winter Park'
    ],
    'Georgia': [
      'Albany', 'Americus', 'Andersonville', 'Athens', 'Atlanta', 'Augusta', 'Bainbridge', 'Blairsville', 'Brunswick', 'Calhoun',
      'Carrollton', 'Columbus', 'Dahlonega', 'Dalton', 'Darien', 'Decatur', 'Douglas', 'East Point', 'Fitzgerald', 'Fort Valley',
      'Gainesville', 'La Grange', 'Macon', 'Marietta', 'Milledgeville', 'Plains', 'Rome', 'Savannah', 'Toccoa', 'Valdosta',
      'Warm Springs', 'Warner Robins', 'Washington', 'Waycross'
    ],
    'Hawaii': [
      'Hanalei', 'Hilo', 'Honaunau', 'Honolulu', 'Kahului', 'Kaneohe', 'Kapaa', 'Kawaihae', 'Lahaina', 'Laie',
      'Wahiawa', 'Wailuku', 'Waimea'
    ],
    'Idaho': [
      'Blackfoot', 'Boise', 'Bonners Ferry', 'Caldwell', 'Coeur d\'Alene', 'Idaho City', 'Idaho Falls', 'Kellogg', 'Lewiston', 'Moscow',
      'Nampa', 'Pocatello', 'Priest River', 'Rexburg', 'Sun Valley', 'Twin Falls'
    ],
    'Illinois': [
      'Alton', 'Arlington Heights', 'Arthur', 'Aurora', 'Belleville', 'Belvidere', 'Bloomington', 'Brookfield', 'Cahokia', 'Cairo',
      'Calumet City', 'Canton', 'Carbondale', 'Carlinville', 'Carthage', 'Centralia', 'Champaign', 'Charleston', 'Chester', 'Chicago',
      'Chicago Heights', 'Cicero', 'Collinsville', 'Danville', 'Decatur', 'DeKalb', 'Des Plaines', 'Dixon', 'East Moline', 'East Saint Louis',
      'Effingham', 'Elgin', 'Elmhurst', 'Evanston', 'Freeport', 'Galena', 'Galesburg', 'Glen Ellyn', 'Glenview', 'Granite City',
      'Harrisburg', 'Herrin', 'Highland Park', 'Jacksonville', 'Joliet', 'Kankakee', 'Kaskaskia', 'Kewanee', 'La Salle', 'Lake Forest',
      'Libertyville', 'Lincoln', 'Lisle', 'Lombard', 'Macomb', 'Mattoon', 'Moline', 'Monmouth', 'Mount Vernon', 'Mundelein',
      'Naperville', 'Nauvoo', 'Normal', 'North Chicago', 'Oak Park', 'Oregon', 'Ottawa', 'Palatine', 'Park Forest', 'Park Ridge',
      'Pekin', 'Peoria', 'Petersburg', 'Pontiac', 'Quincy', 'Rantoul', 'River Forest', 'Rock Island', 'Rockford', 'Salem',
      'Shawneetown', 'Skokie', 'South Holland', 'Springfield', 'Streator', 'Summit', 'Urbana', 'Vandalia', 'Virden', 'Waukegan',
      'Wheaton', 'Wilmette', 'Winnetka', 'Wood River', 'Zion'
    ],
    'Indiana': [
      'Anderson', 'Bedford', 'Bloomington', 'Columbus', 'Connersville', 'Corydon', 'Crawfordsville', 'East Chicago', 'Elkhart', 'Elwood',
      'Evansville', 'Fort Wayne', 'French Lick', 'Gary', 'Geneva', 'Goshen', 'Greenfield', 'Hammond', 'Hobart', 'Huntington',
      'Indianapolis', 'Jeffersonville', 'Kokomo', 'Lafayette', 'Madison', 'Marion', 'Michigan City', 'Mishawaka', 'Muncie', 'Nappanee',
      'Nashville', 'New Albany', 'New Castle', 'New Harmony', 'Peru', 'Plymouth', 'Richmond', 'Santa Claus', 'Shelbyville', 'South Bend',
      'Terre Haute', 'Valparaiso', 'Vincennes', 'Wabash', 'West Lafayette'
    ],
    'Iowa': [
      'Amana Colonies', 'Ames', 'Boone', 'Burlington', 'Cedar Falls', 'Cedar Rapids', 'Charles City', 'Cherokee', 'Clinton', 'Council Bluffs',
      'Davenport', 'Des Moines', 'Dubuque', 'Estherville', 'Fairfield', 'Fort Dodge', 'Grinnell', 'Indianola', 'Iowa City', 'Keokuk',
      'Mason City', 'Mount Pleasant', 'Muscatine', 'Newton', 'Oskaloosa', 'Ottumwa', 'Sioux City', 'Waterloo', 'Webster City', 'West Des Moines'
    ],
    'Kansas': [
      'Abilene', 'Arkansas City', 'Atchison', 'Chanute', 'Coffeyville', 'Council Grove', 'Dodge City', 'Emporia', 'Fort Scott', 'Garden City',
      'Great Bend', 'Hays', 'Hutchinson', 'Independence', 'Junction City', 'Kansas City', 'Lawrence', 'Leavenworth', 'Liberal', 'Manhattan',
      'McPherson', 'Medicine Lodge', 'Newton', 'Olathe', 'Osawatomie', 'Ottawa', 'Overland Park', 'Pittsburg', 'Salina', 'Shawnee',
      'Smith Center', 'Topeka', 'Wichita'
    ],
    'Kentucky': [
      'Ashland', 'Barbourville', 'Bardstown', 'Berea', 'Boonesborough', 'Bowling Green', 'Campbellsville', 'Covington', 'Danville', 'Elizabethtown',
      'Frankfort', 'Harlan', 'Harrodsburg', 'Hazard', 'Henderson', 'Hodgenville', 'Hopkinsville', 'Lexington', 'Louisville', 'Mayfield',
      'Maysville', 'Middlesboro', 'Newport', 'Owensboro', 'Paducah', 'Paris', 'Richmond'
    ],
    'Louisiana': [
      'Abbeville', 'Alexandria', 'Bastrop', 'Baton Rouge', 'Bogalusa', 'Bossier City', 'Gretna', 'Houma', 'Lafayette', 'Lake Charles',
      'Monroe', 'Morgan City', 'Natchitoches', 'New Iberia', 'New Orleans', 'Opelousas', 'Ruston', 'Saint Martinville', 'Shreveport', 'Thibodaux'
    ],
    'Maine': [
      'Auburn', 'Augusta', 'Bangor', 'Bar Harbor', 'Bath', 'Belfast', 'Biddeford', 'Boothbay Harbor', 'Brunswick', 'Calais',
      'Caribou', 'Castine', 'Eastport', 'Ellsworth', 'Farmington', 'Fort Kent', 'Gardiner', 'Houlton', 'Kennebunkport', 'Kittery',
      'Lewiston', 'Lubec', 'Machias', 'Orono', 'Portland', 'Presque Isle', 'Rockland', 'Rumford', 'Saco', 'Scarborough',
      'Waterville', 'York'
    ],
    'Maryland': [
      'Aberdeen', 'Annapolis', 'Baltimore', 'Bethesda-Chevy Chase', 'Bowie', 'Cambridge', 'Catonsville', 'College Park', 'Columbia', 'Cumberland',
      'Easton', 'Elkton', 'Emmitsburg', 'Frederick', 'Greenbelt', 'Hagerstown', 'Hyattsville', 'Laurel', 'Oakland', 'Ocean City',
      'Rockville', 'Saint Marys City', 'Salisbury', 'Silver Spring', 'Takoma Park', 'Towson', 'Westminster'
    ],
    'Massachusetts': [
      'Abington', 'Adams', 'Amesbury', 'Amherst', 'Andover', 'Arlington', 'Athol', 'Attleboro', 'Barnstable', 'Bedford',
      'Beverly', 'Boston', 'Bourne', 'Braintree', 'Brockton', 'Brookline', 'Cambridge', 'Canton', 'Charlestown', 'Chelmsford',
      'Chelsea', 'Chicopee', 'Clinton', 'Cohasset', 'Concord', 'Danvers', 'Dartmouth', 'Dedham', 'Dennis', 'Duxbury',
      'Eastham', 'Edgartown', 'Everett', 'Fairhaven', 'Fall River', 'Falmouth', 'Fitchburg', 'Framingham', 'Gloucester', 'Great Barrington',
      'Greenfield', 'Groton', 'Harwich', 'Haverhill', 'Hingham', 'Holyoke', 'Hyannis', 'Ipswich', 'Lawrence', 'Lenox',
      'Leominster', 'Lexington', 'Lowell', 'Ludlow', 'Lynn', 'Malden', 'Marblehead', 'Marlborough', 'Medford', 'Milton',
      'Nahant', 'Natick', 'New Bedford', 'Newburyport', 'Newton', 'North Adams', 'Northampton', 'Norton', 'Norwood', 'Peabody',
      'Pittsfield', 'Plymouth', 'Provincetown', 'Quincy', 'Randolph', 'Revere', 'Salem', 'Sandwich', 'Saugus', 'Somerville',
      'South Hadley', 'Springfield', 'Stockbridge', 'Stoughton', 'Sturbridge', 'Sudbury', 'Taunton', 'Tewksbury', 'Truro', 'Watertown',
      'Webster', 'Wellesley', 'Wellfleet', 'West Bridgewater', 'West Springfield', 'Westfield', 'Weymouth', 'Whitman', 'Williamstown', 'Woburn',
      'Woods Hole', 'Worcester'
    ],
    'Michigan': [
      'Adrian', 'Alma', 'Ann Arbor', 'Battle Creek', 'Bay City', 'Benton Harbor', 'Bloomfield Hills', 'Cadillac', 'Charlevoix', 'Cheboygan',
      'Dearborn', 'Detroit', 'East Lansing', 'Eastpointe', 'Ecorse', 'Escanaba', 'Flint', 'Grand Haven', 'Grand Rapids', 'Grayling',
      'Grosse Pointe', 'Hancock', 'Highland Park', 'Holland', 'Houghton', 'Interlochen', 'Iron Mountain', 'Ironwood', 'Ishpeming', 'Jackson',
      'Kalamazoo', 'Lansing', 'Livonia', 'Ludington', 'Mackinaw City', 'Manistee', 'Marquette', 'Menominee', 'Midland', 'Monroe',
      'Mount Clemens', 'Mount Pleasant', 'Muskegon', 'Niles', 'Petoskey', 'Pontiac', 'Port Huron', 'Royal Oak', 'Saginaw', 'Saint Ignace',
      'Saint Joseph', 'Sault Sainte Marie', 'Traverse City', 'Trenton', 'Warren', 'Wyandotte', 'Ypsilanti'
    ],
    'Minnesota': [
      'Albert Lea', 'Alexandria', 'Austin', 'Bemidji', 'Bloomington', 'Brainerd', 'Crookston', 'Duluth', 'Ely', 'Eveleth',
      'Faribault', 'Fergus Falls', 'Hastings', 'Hibbing', 'International Falls', 'Little Falls', 'Mankato', 'Minneapolis', 'Moorhead', 'New Ulm',
      'Northfield', 'Owatonna', 'Pipestone', 'Red Wing', 'Rochester', 'Saint Cloud', 'Saint Paul', 'Sauk Centre', 'South Saint Paul', 'Stillwater',
      'Virginia', 'Willmar', 'Winona'
    ],
    'Mississippi': [
      'Bay Saint Louis', 'Biloxi', 'Canton', 'Clarksdale', 'Columbia', 'Columbus', 'Corinth', 'Greenville', 'Greenwood', 'Grenada',
      'Gulfport', 'Hattiesburg', 'Holly Springs', 'Jackson', 'Laurel', 'Meridian', 'Natchez', 'Ocean Springs', 'Oxford', 'Pascagoula',
      'Pass Christian', 'Philadelphia', 'Port Gibson', 'Starkville', 'Tupelo', 'Vicksburg', 'West Point', 'Yazoo City'
    ],
    'Missouri': [
      'Boonville', 'Branson', 'Cape Girardeau', 'Carthage', 'Chillicothe', 'Clayton', 'Columbia', 'Excelsior Springs', 'Ferguson', 'Florissant',
      'Fulton', 'Hannibal', 'Independence', 'Jefferson City', 'Joplin', 'Kansas City', 'Kirksville', 'Lamar', 'Lebanon', 'Lexington',
      'Maryville', 'Mexico', 'Monett', 'Neosho', 'Nevada', 'O\'Fallon', 'Poplar Bluff', 'Raymore', 'Rolla', 'Saint Charles',
      'Saint Clair', 'Saint Joseph', 'Saint Louis', 'Sainte Genevieve', 'Salem', 'Sedalia', 'Springfield', 'Warrensburg', 'West Plains'
    ],
    'Montana': [
      'Anaconda', 'Billings', 'Bozeman', 'Butte', 'Great Falls', 'Havre', 'Helena', 'Kalispell', 'Lewistown', 'Livingston',
      'Miles City', 'Missoula', 'Whitefish'
    ],
    'Nebraska': [
      'Alliance', 'Beatrice', 'Bellevue', 'Columbus', 'Fremont', 'Grand Island', 'Hastings', 'Kearney', 'Lincoln', 'Norfolk',
      'North Platte', 'Omaha', 'Scottsbluff'
    ],
    'Nevada': [
      'Boulder City', 'Carson City', 'Elko', 'Ely', 'Fallon', 'Henderson', 'Las Vegas', 'North Las Vegas', 'Reno', 'Sparks',
      'Virginia City', 'Winnemucca'
    ],
    'New Hampshire': [
      'Berlin', 'Claremont', 'Concord', 'Derry', 'Dover', 'Durham', 'Exeter', 'Franklin', 'Hanover', 'Keene',
      'Laconia', 'Lebanon', 'Manchester', 'Nashua', 'New London', 'Portsmouth', 'Rochester', 'Salem'
    ],
    'New Jersey': [
      'Asbury Park', 'Atlantic City', 'Bayonne', 'Bloomfield', 'Bridgeton', 'Camden', 'Cape May', 'Clifton', 'East Orange', 'Elizabeth',
      'Englewood', 'Fort Lee', 'Hackensack', 'Hoboken', 'Irvington', 'Jersey City', 'Lakewood', 'Long Branch', 'Millville', 'Morristown',
      'Newark', 'New Brunswick', 'Passaic', 'Paterson', 'Perth Amboy', 'Plainfield', 'Princeton', 'Sayreville', 'Trenton', 'Union City',
      'Vineland', 'West New York'
    ],
    'New Mexico': [
      'Acoma', 'Alamogordo', 'Albuquerque', 'Artesia', 'Carlsbad', 'Clovis', 'Deming', 'Farmington', 'Gallup', 'Grants',
      'Hobbs', 'Las Cruces', 'Las Vegas', 'Los Alamos', 'Lovington', 'Portales', 'Roswell', 'Santa Fe', 'Silver City', 'Socorro',
      'Taos', 'Truth or Consequences', 'Tucumcari'
    ],
    'New York': [
      'Albany', 'Amsterdam', 'Auburn', 'Batavia', 'Beacon', 'Buffalo', 'Canandaigua', 'Cohoes', 'Corning', 'Cortland',
      'Dunkirk', 'Elmira', 'Freeport', 'Fulton', 'Geneva', 'Glens Falls', 'Gloversville', 'Hempstead', 'Herkimer', 'Hudson',
      'Huntington', 'Ithaca', 'Jamestown', 'Kingston', 'Lackawanna', 'Lake Placid', 'Lockport', 'Long Beach', 'Massena', 'Middletown',
      'Mount Vernon', 'New Rochelle', 'New York City', 'Newburgh', 'Niagara Falls', 'North Tonawanda', 'Norwich', 'Ogdensburg', 'Olean', 'Oneida',
      'Oneonta', 'Oswego', 'Plattsburgh', 'Port Jervis', 'Poughkeepsie', 'Rochester', 'Rome', 'Saratoga Springs', 'Schenectady', 'Syracuse',
      'Tonawanda', 'Troy', 'Utica', 'Watertown', 'Watervliet', 'White Plains', 'Yonkers'
    ],
    'North Carolina': [
      'Asheville', 'Bath', 'Beaufort', 'Boone', 'Burlington', 'Chapel Hill', 'Charlotte', 'Concord', 'Durham', 'Edenton',
      'Elizabeth City', 'Fayetteville', 'Gastonia', 'Goldsboro', 'Greensboro', 'Greenville', 'Hendersonville', 'Hickory', 'High Point', 'Jacksonville',
      'Kannapolis', 'Kinston', 'Lumberton', 'Monroe', 'Morganton', 'New Bern', 'Pinehurst', 'Raleigh', 'Rocky Mount', 'Salisbury',
      'Sanford', 'Shelby', 'Statesville', 'Washington', 'Wilmington', 'Wilson', 'Winston-Salem'
    ],
    'North Dakota': [
      'Bismarck', 'Devils Lake', 'Dickinson', 'Fargo', 'Grand Forks', 'Jamestown', 'Mandan', 'Minot', 'Valley City', 'Wahpeton',
      'West Fargo', 'Williston'
    ],
    'Ohio': [
      'Akron', 'Alliance', 'Ashtabula', 'Athens', 'Barberton', 'Bedford', 'Bellefontaine', 'Bowling Green', 'Cambridge', 'Canton',
      'Chillicothe', 'Cincinnati', 'Cleveland', 'Cleveland Heights', 'Columbus', 'Conneaut', 'Cuyahoga Falls', 'Dayton', 'Defiance', 'Delaware',
      'East Cleveland', 'Elyria', 'Euclid', 'Findlay', 'Gallipolis', 'Hamilton', 'Kent', 'Kettering', 'Lakewood', 'Lancaster',
      'Lima', 'Lorain', 'Mansfield', 'Marietta', 'Marion', 'Massillon', 'Middletown', 'Mount Vernon', 'Newark', 'Norwalk',
      'Oberlin', 'Painesville', 'Parma', 'Portsmouth', 'Reynoldsburg', 'Sandusky', 'Shaker Heights', 'Springfield',
      'Steubenville', 'Toledo', 'Troy', 'Urbana', 'Warren', 'Wooster', 'Xenia', 'Youngstown', 'Zanesville'
    ],
    'Oklahoma': [
      'Ada', 'Altus', 'Anadarko', 'Ardmore', 'Bartlesville', 'Bethany', 'Chickasha', 'Claremore', 'Duncan', 'Durant',
      'Edmond', 'El Reno', 'Enid', 'Guthrie', 'Guymon', 'Lawton', 'McAlester', 'Muskogee', 'Norman', 'Oklahoma City',
      'Okmulgee', 'Pawhuska', 'Ponca City', 'Pryor', 'Sapulpa', 'Shawnee', 'Stillwater', 'Tahlequah', 'Tulsa', 'Vinita'
    ],
    'Oregon': [
      'Albany', 'Astoria', 'Baker City', 'Bend', 'Corvallis', 'Eugene', 'Grants Pass', 'Hillsboro', 'Hood River', 'Klamath Falls',
      'La Grande', 'Lake Oswego', 'McMinnville', 'Medford', 'Newberg', 'Newport', 'Oregon City', 'Pendleton', 'Portland', 'Roseburg',
      'Salem', 'Springfield', 'The Dalles', 'Tillamook'
    ],
    'Pennsylvania': [
      'Allentown', 'Altoona', 'Bethlehem', 'Bradford', 'Bristol', 'Carbondale', 'Chester', 'Columbia', 'Easton', 'Erie',
      'Gettysburg', 'Greensburg', 'Hanover', 'Harrisburg', 'Hazleton', 'Hershey', 'Johnstown', 'Lancaster', 'Lebanon', 'Levittown',
      'McKeesport', 'Meadville', 'New Castle', 'Norristown', 'Oil City', 'Philadelphia', 'Phoenixville', 'Pittsburgh', 'Pottstown', 'Pottsville',
      'Reading', 'Scranton', 'Sharon', 'Uniontown', 'Warren', 'Washington', 'West Chester', 'Wilkes-Barre', 'Williamsport', 'York'
    ],
    'Rhode Island': [
      'Bristol', 'Cranston', 'East Greenwich', 'East Providence', 'Kingston', 'Middletown', 'Newport', 'North Kingstown', 'Pawtucket', 'Portsmouth',
      'Providence', 'South Kingstown', 'Warwick', 'Westerly', 'Woonsocket'
    ],
    'South Carolina': [
      'Aiken', 'Anderson', 'Beaufort', 'Camden', 'Charleston', 'Columbia', 'Darlington', 'Florence', 'Fort Sumter', 'Georgetown',
      'Greenville', 'Greenwood', 'Hilton Head', 'Mount Pleasant', 'Myrtle Beach', 'North Charleston', 'Rock Hill', 'Spartanburg', 'Sumter'
    ],
    'South Dakota': [
      'Aberdeen', 'Brookings', 'Deadwood', 'Hot Springs', 'Huron', 'Lead', 'Mitchell', 'Mobridge', 'Pierre', 'Rapid City',
      'Sioux Falls', 'Spearfish', 'Sturgis', 'Vermillion', 'Watertown', 'Yankton'
    ],
    'Tennessee': [
      'Bristol', 'Chattanooga', 'Clarksville', 'Columbia', 'Cookeville', 'Franklin', 'Gatlinburg', 'Greeneville', 'Jackson', 'Johnson City',
      'Kingsport', 'Knoxville', 'Lebanon', 'McMinnville', 'Memphis', 'Murfreesboro', 'Nashville', 'Oak Ridge', 'Shelbyville', 'Union City'
    ],
    'Texas': [
      'Abilene', 'Amarillo', 'Arlington', 'Austin', 'Baytown', 'Beaumont', 'Brownsville', 'Bryan', 'College Station', 'Corpus Christi',
      'Dallas', 'Denton', 'El Paso', 'Fort Worth', 'Galveston', 'Garland', 'Grand Prairie', 'Houston', 'Irving', 'Killeen',
      'Laredo', 'Lubbock', 'McAllen', 'Mesquite', 'Midland', 'Odessa', 'Pasadena', 'Plano', 'Port Arthur', 'Richardson',
      'Round Rock', 'San Angelo', 'San Antonio', 'Tyler', 'Waco', 'Wichita Falls'
    ],
    'Utah': [
      'Bountiful', 'Cedar City', 'Clearfield', 'Layton', 'Logan', 'Moab', 'Ogden', 'Orem', 'Park City', 'Provo',
      'Saint George', 'Salt Lake City', 'Sandy', 'West Jordan', 'West Valley City'
    ],
    'Vermont': [
      'Barre', 'Bellows Falls', 'Bennington', 'Brattleboro', 'Burlington', 'Essex', 'Manchester', 'Middlebury', 'Montpelier', 'Newport',
      'Rutland', 'Saint Albans', 'Saint Johnsbury', 'Shelburne', 'Stowe', 'Waterbury', 'White River Junction', 'Windsor'
    ],
    'Virginia': [
      'Alexandria', 'Bristol', 'Charlottesville', 'Chesapeake', 'Danville', 'Fredericksburg', 'Hampton', 'Harrisonburg', 'Lexington', 'Lynchburg',
      'Manassas', 'Newport News', 'Norfolk', 'Petersburg', 'Portsmouth', 'Radford', 'Richmond', 'Roanoke', 'Suffolk', 'Virginia Beach',
      'Williamsburg', 'Winchester'
    ],
    'Washington': [
      'Aberdeen', 'Anacortes', 'Bellingham', 'Bremerton', 'Centralia', 'Ellensburg', 'Everett', 'Federal Way', 'Olympia', 'Pasco',
      'Port Angeles', 'Pullman', 'Puyallup', 'Redmond', 'Renton', 'Seattle', 'Spokane', 'Tacoma', 'Vancouver', 'Walla Walla',
      'Wenatchee', 'Yakima'
    ],
    'West Virginia': [
      'Beckley', 'Bluefield', 'Buckhannon', 'Charles Town', 'Charleston', 'Clarksburg', 'Elkins', 'Fairmont', 'Grafton', 'Harpers Ferry',
      'Huntington', 'Keyser', 'Lewisburg', 'Logan', 'Martinsburg', 'Morgantown', 'Moundsville', 'New Martinsville', 'Parkersburg', 'Philippi',
      'Point Pleasant', 'Princeton', 'Ranson', 'Romney', 'Shepherdstown', 'Summersville', 'Weirton', 'Welch', 'Wellsburg', 'Wheeling'
    ],
    'Wisconsin': [
      'Appleton', 'Baraboo', 'Beloit', 'Eau Claire', 'Fond du Lac', 'Green Bay', 'Janesville', 'Kenosha', 'La Crosse', 'Madison',
      'Manitowoc', 'Marinette', 'Menomonie', 'Milwaukee', 'Neenah', 'New London', 'Oshkosh', 'Platteville', 'Portage', 'Prairie du Chien',
      'Racine', 'Sheboygan', 'Stevens Point', 'Superior', 'Watertown', 'Waukesha', 'Wausau', 'Wisconsin Dells'
    ],
    'Wyoming': [
      'Casper', 'Cheyenne', 'Cody', 'Evanston', 'Gillette', 'Green River', 'Jackson', 'Laramie', 'Rawlins', 'Rock Springs',
      'Sheridan', 'Thermopolis', 'Torrington', 'Worland'
    ]
  },
  'Canada': {
    'Alberta': [
      'Banff', 'Calgary', 'Camrose', 'Drumheller', 'Edmonton', 'Fort McMurray', 'Grande Prairie', 'Jasper', 'Lethbridge', 'Medicine Hat',
      'Red Deer', 'Wetaskiwin'
    ],
    'British Columbia': [
      'Abbotsford', 'Burnaby', 'Campbell River', 'Chilliwack', 'Courtenay', 'Cranbrook', 'Dawson Creek', 'Delta', 'Kamloops', 'Kelowna',
      'Langley', 'Nanaimo', 'New Westminster', 'North Vancouver', 'Penticton', 'Port Alberni', 'Port Coquitlam', 'Prince George', 'Prince Rupert', 'Richmond',
      'Surrey', 'Vancouver', 'Vernon', 'Victoria', 'West Vancouver', 'White Rock'
    ],
    'Manitoba': [
      'Brandon', 'Dauphin', 'Flin Flon', 'Portage la Prairie', 'Selkirk', 'Steinbach', 'Thompson', 'Winkler', 'Winnipeg'
    ],
    'New Brunswick': [
      'Bathurst', 'Campbellton', 'Dieppe', 'Edmundston', 'Fredericton', 'Miramichi', 'Moncton', 'Saint John'
    ],
    'Newfoundland and Labrador': [
      'Corner Brook', 'Gander', 'Grand Falls-Windsor', 'Happy Valley-Goose Bay', 'Labrador City', 'Mount Pearl', 'St. Johns'
    ],
    'Northwest Territories': [
      'Fort Smith', 'Hay River', 'Inuvik', 'Yellowknife'
    ],
    'Nova Scotia': [
      'Amherst', 'Antigonish', 'Bridgewater', 'Dartmouth', 'Digby', 'Glace Bay', 'Halifax', 'Kentville', 'New Glasgow', 'Sydney',
      'Truro', 'Windsor', 'Yarmouth'
    ],
    'Nunavut': [
      'Iqaluit', 'Rankin Inlet'
    ],
    'Ontario': [
      'Ajax', 'Aurora', 'Barrie', 'Belleville', 'Brampton', 'Brantford', 'Burlington', 'Cambridge', 'Chatham', 'Cornwall',
      'Etobicoke', 'Guelph', 'Hamilton', 'Kingston', 'Kitchener', 'London', 'Markham', 'Mississauga', 'Niagara Falls', 'North Bay',
      'Oakville', 'Oshawa', 'Ottawa', 'Owen Sound', 'Peterborough', 'Pickering', 'Richmond Hill', 'Sarnia', 'Sault Ste. Marie', 'Scarborough',
      'St. Catharines', 'Sudbury', 'Thunder Bay', 'Timmins', 'Toronto', 'Vaughan', 'Waterloo', 'Welland', 'Windsor', 'York'
    ],
    'Prince Edward Island': [
      'Charlottetown', 'Summerside'
    ],
    'Quebec': [
      'Chicoutimi', 'Drummondville', 'Gatineau', 'Hull', 'Laval', 'Longueuil', 'Montreal', 'Quebec City', 'Rimouski', 'Rouyn-Noranda',
      'Saguenay', 'Sherbrooke', 'Trois-Rivieres', 'Val-dOr'
    ],
    'Saskatchewan': [
      'Estevan', 'Humboldt', 'Lloydminster', 'Moose Jaw', 'North Battleford', 'Prince Albert', 'Regina', 'Saskatoon', 'Swift Current', 'Yorkton'
    ],
    'Yukon': [
      'Whitehorse'
    ]
  },
  'Mexico': {
    'Aguascalientes': [
      'Aguascalientes', 'Calvillo'
    ],
    'Baja California': [
      'Ensenada', 'Mexicali', 'Tecate', 'Tijuana'
    ],
    'Baja California Sur': [
      'Cabo San Lucas', 'La Paz', 'Los Cabos', 'San Jose del Cabo'
    ],
    'Campeche': [
      'Campeche', 'Ciudad del Carmen'
    ],
    'Chiapas': [
      'San Cristobal de las Casas', 'Tapachula', 'Tuxtla Gutierrez'
    ],
    'Chihuahua': [
      'Chihuahua', 'Ciudad Juarez', 'Delicias', 'Parral'
    ],
    'Coahuila': [
      'Monclova', 'Piedras Negras', 'Saltillo', 'Torreon'
    ],
    'Colima': [
      'Colima', 'Manzanillo'
    ],
    'Durango': [
      'Durango', 'Gomez Palacio', 'Lerdo'
    ],
    'Guanajuato': [
      'Celaya', 'Guanajuato', 'Irapuato', 'Leon', 'Salamanca'
    ],
    'Guerrero': [
      'Acapulco', 'Chilpancingo', 'Iguala', 'Taxco'
    ],
    'Hidalgo': [
      'Pachuca', 'Tulancingo'
    ],
    'Jalisco': [
      'Guadalajara', 'Puerto Vallarta', 'Tlaquepaque', 'Zapopan'
    ],
    'Mexico': [
      'Ecatepec', 'Naucalpan', 'Nezahualcoyotl', 'Tlalnepantla', 'Toluca'
    ],
    'Michoacan': [
      'Morelia', 'Uruapan', 'Zamora'
    ],
    'Morelos': [
      'Cuernavaca', 'Cuautla'
    ],
    'Nayarit': [
      'Tepic'
    ],
    'Nuevo Leon': [
      'Guadalupe', 'Monterrey', 'San Nicolas de los Garza'
    ],
    'Oaxaca': [
      'Oaxaca', 'Salina Cruz'
    ],
    'Puebla': [
      'Puebla', 'Tehuacan'
    ],
    'Queretaro': [
      'Queretaro', 'San Juan del Rio'
    ],
    'Quintana Roo': [
      'Cancun', 'Chetumal', 'Cozumel', 'Playa del Carmen'
    ],
    'San Luis Potosi': [
      'San Luis Potosi', 'Soledad de Graciano Sanchez'
    ],
    'Sinaloa': [
      'Culiacan', 'Los Mochis', 'Mazatlan'
    ],
    'Sonora': [
      'Hermosillo', 'Nogales'
    ],
    'Tabasco': [
      'Villahermosa'
    ],
    'Tamaulipas': [
      'Ciudad Victoria', 'Matamoros', 'Nuevo Laredo', 'Reynosa', 'Tampico'
    ],
    'Tlaxcala': [
      'Tlaxcala'
    ],
    'Veracruz': [
      'Coatzacoalcos', 'Cordoba', 'Orizaba', 'Poza Rica', 'Veracruz', 'Xalapa'
    ],
    'Yucatan': [
      'Merida', 'Valladolid'
    ],
    'Zacatecas': [
      'Fresnillo', 'Zacatecas'
    ]
  }
};
      