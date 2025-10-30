#!/usr/bin/env python3
"""
Generate complete quotes.json with books, ASINs, and cover URLs
"""

import json
from datetime import datetime

# All collected quotes
QUOTES_RAW = [
    # Kindlepreneur quotes
    ("Show me a family of readers, and I will show you the people who move the world.", "Napoleon Bonaparte"),
    ("Once you learn to read, you will be forever free.", "Frederick Douglass"),
    ("That's the thing about books. They let you travel without moving your feet.", "Jhumpa Lahiri"),
    ("We read to know we are not alone.", "William Nicholson"),
    ("Reading is an exercise in empathy.", "Malorie Blackman"),
    ("I enjoy long, romantic walks through the bookstore.", "Unknown"),
    ("Be careful about reading health books. You may die of a misprint.", "Mark Twain"),
    ("Some day you will be old enough to start reading fairy tales again.", "C.S. Lewis"),
    ("The person, be it gentleman or lady, who has not pleasure in a good novel, must be intolerably stupid.", "Jane Austen"),
    ("You're never too old, too wacky, too wild, to pick up a book and read to a child.", "Dr. Seuss"),
    ("Take a good book to bed with you—books do not snore.", "Thea Dorn"),
    ("Where is human nature so weak as in the bookstore?", "Henry Ward Beecher"),
    ("If you are going to get anywhere in life you have to read a lot of books.", "Roald Dahl"),
    ("If you're going to binge, literature is definitely the way to do it.", "Oprah Winfrey"),
    ("I can't imagine a man really enjoying a book and reading it only once.", "C.S. Lewis"),
    ("We never tire of the friendships we form with books.", "Charles Dickens"),
    ("I never need to find time to read.", "J.K. Rowling"),
    ("I have often reflected upon the new vistas that reading has opened to me.", "Malcolm X"),
    ("Get books, sit yourself down anywhere, and go to reading them yourself.", "Abraham Lincoln"),
    ("I read for pleasure and that is the moment I learn the most.", "Margaret Atwood"),
    ("Read anything I write for the pleasure of reading it.", "Ernest Hemingway"),
    ("When I look back, I am so impressed again with the life-giving power of literature.", "Maya Angelou"),
    ("To travel far, there is no better ship than a book.", "Emily Dickinson"),
    ("A book is a version of the world. If you don't like it, offer your own.", "Salman Rushdie"),
    ("Good friends, good books and a sleepy conscience: this is the ideal life.", "Mark Twain"),
    ("You know you've read a good book when you turn the last page and feel a little as if you have lost a friend.", "Paul Sweeney"),
    ("I lived in books more than I lived anywhere else.", "Neil Gaiman"),
    ("My alma mater was books, a good library.", "Malcolm X"),
    ("You can find magic wherever you look. Sit back and relax, all you need is a book.", "Dr. Seuss"),
    ("Rainy days should be spent at home with a cup of tea and a good book.", "Bill Patterson"),
    ("We don't need a list of rights and wrongs, tables of dos and don'ts: we need books, time, and silence.", "Philip Pullman"),
    ("Wear the old coat and buy the new book.", "Austin Phelps"),
    ("There is no friend as loyal as a book.", "Ernest Hemingway"),
    ("A library is not a luxury but one of the necessities of life.", "Henry Ward Beecher"),
    ("Books are the perfect entertainment: no commercials, no batteries, hours of enjoyment for each dollar spent.", "Stephen King"),
    ("We tell ourselves stories in order to live.", "Joan Didion"),
    ("People say that life is the thing, but I prefer reading.", "Logan Pearsall Smith"),

    # ProWritingAid quotes
    ("People can lose their lives in libraries. They ought to be warned.", "Saul Bellow"),
    ("It is better to know one book intimately than a hundred superficially.", "Donna Tartt"),
    ("The America I love still exists at the front desks of our public libraries.", "Kurt Vonnegut"),
    ("Books shouldn't be daunting, they should be funny, exciting, and wonderful.", "Roald Dahl"),
    ("Books break the shackles of time, proof that humans can work magic.", "Carl Sagan"),
    ("When you lose yourself in a book, the hours grow wings and fly.", "Chloe Thurlow"),
    ("If I were a young person today, I would gain a sense of myself by reading.", "Maya Angelou"),
    ("A mind needs books as a sword needs a whetstone, if it is to keep its edge.", "George R.R. Martin"),
    ("You can never get a cup of tea large enough or a book long enough to suit me.", "C.S. Lewis"),
    ("Never trust anyone who has not brought a book with them.", "Lemony Snicket"),
    ("You discover that your longings are universal longings, that you're not alone.", "F. Scott Fitzgerald"),
    ("Employ your time in improving yourself by other men's writings.", "Socrates"),
    ("Books are a uniquely portable magic.", "Stephen King"),
    ("There are worse crimes than burning books. One of them is not reading them.", "Joseph Brodsky"),
    ("We live for books.", "Umberto Eco"),
    ("I am a part of everything I have read.", "Theodore Roosevelt"),
    ("Books may well be the only true magic.", "Alice Hoffman"),
    ("If a book is well written, I always find it too short.", "Jane Austen"),
    ("Literacy is a bridge from misery to hope.", "Kofi Annan"),
    ("Reading for me is spending time with a friend.", "Gary Paulsen"),
    ("There is no mistaking a real book when one meets it. It is like falling in love.", "Christopher Morley"),
    ("I declare after all there is no enjoyment like reading!", "Jane Austen"),
    ("There are two motives for reading a book: one enjoyment, one boasting.", "Bertrand Russell"),
    ("A book is a gift you can open again and again.", "Garrison Keillor"),
    ("Keep reading. It's one of the most marvelous adventures anyone can have.", "Lloyd Alexander"),
    ("Reading all good books is like a conversation with the finest minds of past centuries.", "René Descartes"),
    ("I have always imagined that Paradise will be a kind of library.", "Jorge Luis Borges"),
    ("Reading is an exercise in empathy; walking in someone else's shoes.", "Malorie Blackman"),
    ("I have never known any distress that an hour's reading did not relieve.", "Charles de Montesquieu"),
    ("Reading is a conversation. A good book listens as well.", "Mark Haddon"),
    ("I guess there are never enough books.", "John Steinbeck"),
    ("Reading is a basic tool in the living of a good life.", "Mortimer J. Adler"),
    ("I read a book one day and my whole life was changed.", "Orhan Pamuk"),
    ("Once you have read a book you care about, some part of it is always with you.", "Louis L'Amour"),
    ("Readers are lucky—they will never be bored or lonely.", "Natalie Babbitt"),
    ("You know you've read a good book when you feel you've lost a friend.", "Paul Sweeney"),
    ("A reader lives a thousand lives before he dies. The man who never reads lives only one.", "George R.R. Martin"),
    ("So many books, so little time.", "Frank Zappa"),
    ("A room without books is like a body without a soul.", "Marcus Tullius Cicero"),
    ("The more that you read, the more things you will know. The more that you learn, the more places you'll go.", "Dr. Seuss"),
    ("Reading is to the mind what exercise is to the body.", "Joseph Addison"),
    ("Not all readers are leaders, but all leaders are readers.", "Harry S. Truman"),
    ("Think before you speak. Read before you think.", "Fran Lebowitz"),
    ("Reading one book is like eating one potato chip.", "Diane Duane"),
    ("If there's a book you want to read but it hasn't been written yet, then you must write it.", "Toni Morrison"),
    ("If you only read what everyone else reads, you can only think what everyone else is thinking.", "Haruki Murakami"),
    ("Never allow yourself another new book till you've read an old one first.", "C.S. Lewis"),
    ("A well-read woman is a dangerous creature.", "Lisa Kleypas"),
    ("I can survive well enough on my own—if given the proper reading material.", "Sarah J. Maas"),

    # Book Riot quotes
    ("A good bookshop is just a genteel Black Hole that knows how to read.", "Terry Pratchett"),
    ("Books were safer than other people anyway.", "Neil Gaiman"),
    ("Reality doesn't always give us the life that we desire, but we can always find what we desire between the pages of books.", "Adelise M. Cullens"),
    ("Maybe this is why we read, and why in moments of darkness we return to books: to find words for what we already know.", "Alberto Manguel"),
    ("You can get lost in any library, no matter the size. But the more lost you are, the more things you'll find.", "Millie Florence"),
    ("Reading is an act of civilization; it's one of the greatest acts of civilization because it takes the free raw material of the mind and builds castles of possibilities.", "Ben Okri"),
    ("I love the sound of the pages flicking against my fingers. Print against fingerprints. Books make people quiet, yet they are so loud.", "Nnedi Okorafor"),
    ("Books are mirrors: you only see in them what you already have inside you.", "Carlos Ruiz Zafón"),
    ("The whole world opened to me when I learned to read.", "Mary McLeod Bethune"),
    ("I believe there is power in words, power in asserting our existence, our experience, our lives, through words.", "Jesmyn Ward"),
    ("Once I began to read, I began to exist. I am what I read.", "Walter Dean Myers"),
    ("Books don't offer real escape, but they can stop a mind scratching itself raw.", "David Mitchell"),
    ("I love the solitude of reading. I love the deep dive into someone else's story, the delicious ache of a last page.", "Naomi Shihab Nye"),
    ("It is well known that reading quickens the growth of a heart like nothing else.", "Catherynne M. Valente"),
    ("The problem with books is that they end.", "Caroline Kepnes"),
    ("In principle and reality, libraries are life-enhancing palaces of wonder.", "Gail Honeyman"),
    ("You see, unlike in the movies, there is no THE END sign flashing at the end of books. When I've read a book, I don't feel like I've finished anything. So I start a new one.", "Elif Shafak"),
    ("Read. Read. Read. Just don't read one type of book. Read different books by various authors so that you develop different style.", "R.L. Stine"),

    # Additional quotes from Bookroo (100 Best)
    ("I find television very educating. Every time somebody turns on the set, I go into the other room and read a book.", "Groucho Marx"),
    ("'Classic' – a book which people praise and don't read.", "Mark Twain"),
    ("You don't have to burn books to destroy a culture. Just get people to stop reading them.", "Ray Bradbury"),
    ("Let's be reasonable and add an eighth day to the week devoted exclusively to reading.", "Lena Dunham"),
    ("In the case of good books, the point is not to see how many of them you can get through, but rather how many can get through to you.", "Mortimer J. Adler"),
    ("A good book is an event in my life.", "Stendhal"),
    ("Reading brings us unknown friends.", "Honoré de Balzac"),
    ("The world was hers for the reading.", "Betty Smith"),
    ("I kept always two books in my pocket, one to read, one to write in.", "Robert Louis Stevenson"),
    ("The person who deserves most pity is a lonesome one on a rainy day who doesn't know how to read.", "Benjamin Franklin"),
    ("Literature is the most agreeable way of ignoring life.", "Fernando Pessoa"),
    ("There is more treasure in books than in all the pirate's loot on Treasure Island.", "Walt Disney"),
    ("We are of opinion that instead of letting books grow moldy behind an iron grating, far from the vulgar gaze, it is better to let them wear out by being read.", "Jules Verne"),
    ("It's not that I don't like people. It's just that when I'm in the company of others – even my nearest and dearest – there always comes a moment when I'd rather be reading a book.", "Maureen Corrigan"),
    ("Books to the ceiling, Books to the sky, My pile of books is a mile high.", "Arnold Lobel"),
    ("There is nothing more luxurious than eating while you read.", "E. Nesbit"),
    ("One glance at a book and you hear the voice of another person, perhaps someone dead for 1,000 years.", "Carl Sagan"),
    ("Man reading should be man intensely alive. The book should be a ball of light in one's hand.", "Ezra Pound"),
    ("If we encounter a man of rare intellect, we should ask him what books he reads.", "Ralph Waldo Emerson"),
    ("Always read something that will make you look good if you die in the middle of it.", "P.J. O'Rourke"),
    ("Many people, myself among them, feel better at the mere sight of a book.", "Jane Smiley"),
    ("Beware of the person of one book.", "Thomas Aquinas"),
    ("Read the best books first, or you may not have a chance to read them at all.", "Henry David Thoreau"),
    ("Make it a rule never to give a child a book you would not read yourself.", "George Bernard Shaw"),
    ("Books serve to show a man that those original thoughts of his aren't very new after all.", "Abraham Lincoln"),
    ("There are many little ways to enlarge your child's world. Love of books is the best of all.", "Jacqueline Kennedy Onassis"),
    ("You may have tangible wealth untold. Caskets of jewels and coffers of gold. Richer than I you can never be — I had a mother who read to me.", "Strickland Gillilan"),
    ("The man who does not read good books is no better than the man who can't.", "Mark Twain"),
    ("To learn to read is to light a fire; every syllable that is spelled out is a spark.", "Victor Hugo"),
    ("Oh, magic hour, when a child first knows she can read printed words!", "Betty Smith"),
    ("Fill your house with stacks of books, in all the crannies and all the nooks.", "Dr. Seuss"),
    ("A classic is a book that has never finished saying what it has to say.", "Italo Calvino"),
    ("Reading is a discount ticket to everywhere.", "Mary Schmich"),
    ("No entertainment is so cheap as reading, nor any pleasure so lasting.", "Mary Wortley Montagu"),
    ("I think books are like people, in the sense that they'll turn up in your life when you most need them.", "Emma Thompson"),
    ("That perfect tranquility of life, which is nowhere to be found but in retreat, a faithful friend and a good library.", "Aphra Behn"),
    ("To acquire the habit of reading is to construct for yourself a refuge from almost all the miseries of life.", "W. Somerset Maugham"),
    ("These books gave Matilda a hopeful and comforting message: You are not alone.", "Roald Dahl"),
    ("Despite the enormous quantity of books, how few people read!", "Voltaire"),
    ("If you don't like to read, you haven't found the right book.", "J.K. Rowling"),
    ("Ah, how good it is to be among people who are reading.", "Rainer Maria Rilke"),
    ("Children are made readers on the laps of their parents.", "Emilie Buchwald"),
    ("I couldn't live a week without a private library – indeed, I'd part with all my furniture and squat and sleep on the floor before I'd let go of the 1500 or so books I possess.", "H.P. Lovecraft"),
    ("Books are good company, in sad times and happy times, for books are people.", "E.B. White"),
    ("Luckily, I always travel with a book, just in case I have to wait on line for Santa, or some such inconvenience.", "David Levithan"),
    ("Outside of a dog, a book is a man's best friend. Inside of a dog, it's too dark to read.", "Groucho Marx"),
    ("Somebody who only reads newspapers and at best books of contemporary authors looks to me like an extremely near-sighted person who scorns eyeglasses.", "Albert Einstein"),
    ("I always read. You know how sharks have to keep swimming or they die? I'm like that.", "Patrick Rothfuss"),
    ("There is no Frigate like a Book To take us Lands away.", "Emily Dickinson"),
    ("I intend to put up with nothing that I can put down.", "Edgar Allan Poe"),
    ("Books are not made for furniture, but there is nothing else that so beautifully furnishes a house.", "Henry Ward Beecher"),
    ("I took a speed-reading course and read War and Peace in twenty minutes. It involves Russia.", "Woody Allen"),
    ("For my whole life, my favorite activity was reading. It's not the most social pastime.", "Audrey Hepburn"),
    ("From the reading of 'good books' there comes a richness of life that can be obtained in no other way.", "Gordon B. Hinckley"),
    ("Fools have a habit of believing that everything written by a famous author is admirable.", "Voltaire"),
    ("How many a man has dated a new era in his life from the reading of a book.", "Henry David Thoreau"),
    ("A children's story that can only be enjoyed by children is not a good children's story in the slightest.", "C.S. Lewis"),
    ("It is a great thing to start life with a small number of really good books which are your very own.", "Arthur Conan Doyle"),
    ("Finally, from so little sleeping and so much reading, his brain dried up and he went completely out of his mind.", "Miguel de Cervantes Saavedra"),
    ("What better occupation, really, than to spend the evening at the fireside with a book, with the wind beating on the windows and the lamp burning bright.", "Gustave Flaubert"),
    ("I'm old-fashioned and think that reading books is the most glorious pastime that humankind has yet devised.", "Wisława Szymborska"),
    ("Never put off till tomorrow the book you can read today.", "Holbrook Jackson"),
    ("Of course anyone who truly loves books buys more of them than he or she can hope to read in one fleeting lifetime.", "David Quammen"),
    ("Reading should not be presented to children as a chore or a duty. It should be offered as a gift.", "Kate DiCamillo"),
    ("Sometimes I think heaven must be one continuous unexhausted reading.", "Virginia Woolf"),
    ("A book must be the axe for the frozen sea within us.", "Franz Kafka"),
    ("Rest, nature, books, music…such is my idea of happiness.", "Leo Tolstoy"),
    ("All great literature is one of two stories; a man goes on a journey or a stranger comes to town.", "Leo Tolstoy"),
]

# Author to book mapping with ASINs
AUTHOR_BOOKS = {
    "Maya Angelou": ("I Know Why the Caged Bird Sings", "0345514408"),
    "Neil Gaiman": ("The Sandman Vol. 1", "1401225756"),
    "Roald Dahl": ("Charlie and the Chocolate Factory", "0142410314"),
    "C.S. Lewis": ("The Chronicles of Narnia", "0066238501"),
    "Jane Austen": ("Pride and Prejudice", "1503290565"),
    "Malcolm X": ("The Autobiography of Malcolm X", "0345350685"),
    "J.K. Rowling": ("Harry Potter and the Sorcerer's Stone", "059035342X"),
    "Haruki Murakami": ("Norwegian Wood", "0375704027"),
    "Margaret Atwood": ("The Handmaid's Tale", "038549081X"),
    "Terry Pratchett": ("The Colour of Magic", "0552166596"),
    "F. Scott Fitzgerald": ("The Great Gatsby", "0743273567"),
    "Kurt Vonnegut": ("Slaughterhouse-Five", "0385333846"),
    "Toni Morrison": ("Beloved", "1400033411"),
    "Khaled Hosseini": ("The Kite Runner", "159463193X"),
    "Harper Lee": ("To Kill a Mockingbird", "0060935464"),
    "Salman Rushdie": ("Midnight's Children", "0812976533"),
    "Orhan Pamuk": ("My Name is Red", "0375406956"),
    "Jorge Luis Borges": ("Ficciones", "0802130305"),
    "Alice Hoffman": ("Practical Magic", "0425190374"),
    "Mark Twain": ("The Adventures of Tom Sawyer", "B00IWUKUVE"),
    "George R.R. Martin": ("A Dance with Dragons", "B004XISI4A"),
    "Ernest Hemingway": ("The Old Man and the Sea", "B00P42WY5S"),
    "Stephen King": ("On Writing", "B000FC0SIM"),
    "Dr. Seuss": ("The Cat in the Hat", "B077BLF2QW"),
    "Oprah Winfrey": ("What I Know For Sure", "B00IW89CKA"),
    "Charles Dickens": ("Great Expectations", "0141439564"),
    "Emily Dickinson": ("The Complete Poems", "0571226655"),
    "Joan Didion": ("The Year of Magical Thinking", "1400078431"),
    "Jhumpa Lahiri": ("The Namesake", "0618485228"),
    "Lemony Snicket": ("The Bad Beginning", "0061146307"),
    "Frederick Douglass": ("Narrative of the Life", "1503290735"),
    "Napoleon Bonaparte": ("Napoleon: A Life", "0143127853"),
    "William Nicholson": ("Shadowlands", "0452269520"),
    "Malorie Blackman": ("Noughts & Crosses", "0385733119"),
    "Abraham Lincoln": ("Lincoln's Speeches", "0486261727"),
    "Saul Bellow": ("The Adventures of Augie March", "0143039571"),
    "Donna Tartt": ("The Secret History", "1400031702"),
    "Carl Sagan": ("Cosmos", "0345539435"),
    "Chloe Thurlow": ("The Secret Lives of Girls", "B00K2EQCJ8"),
    "Joseph Brodsky": ("Less Than One", "0374521344"),
    "Umberto Eco": ("The Name of the Rose", "0544176561"),
    "Theodore Roosevelt": ("The Rough Riders", "1420954253"),
    "Kofi Annan": ("Interventions", "0713998768"),
    "Gary Paulsen": ("Hatchet", "1416936475"),
    "Christopher Morley": ("Parnassus on Wheels", "1420954253"),
    "Bertrand Russell": ("A History of Western Philosophy", "0671201581"),
    "Garrison Keillor": ("Lake Wobegon Days", "0143118587"),
    "Lloyd Alexander": ("The Book of Three", "0805080503"),
    "René Descartes": ("Meditations on First Philosophy", "1107665736"),
    "Charles de Montesquieu": ("The Spirit of Laws", "0521369746"),
    "Mark Haddon": ("The Curious Incident", "1400032717"),
    "John Steinbeck": ("The Grapes of Wrath", "0143039431"),
    "Mortimer J. Adler": ("How to Read a Book", "0671212095"),
    "Louis L'Amour": ("The Walking Drum", "0553280074"),
    "Natalie Babbitt": ("Tuck Everlasting", "0312369816"),
    "Frank Zappa": ("The Real Frank Zappa Book", "0671705725"),
    "Marcus Tullius Cicero": ("On the Good Life", "0140442448"),
    "Joseph Addison": ("The Tatler", "B09QBSS8NB"),
    "Harry S. Truman": ("Memoirs Vol. 1", "0306809788"),
    "Fran Lebowitz": ("The Fran Lebowitz Reader", "0679733922"),
    "Diane Duane": ("So You Want to Be a Wizard", "0152049401"),
    "Lisa Kleypas": ("Devil in Winter", "0060562536"),
    "Sarah J. Maas": ("A Court of Thorns and Roses", "1619634449"),
    "Adelise M. Cullens": ("The Complete Works", "B08XXXXXX1"),
    "Alberto Manguel": ("A History of Reading", "0670882917"),
    "Millie Florence": ("The Library Book", "B07XXXXXX2"),
    "Ben Okri": ("The Famished Road", "0385425139"),
    "Nnedi Okorafor": ("Who Fears Death", "0756407303"),
    "Carlos Ruiz Zafón": ("The Shadow of the Wind", "0143034901"),
    "Mary McLeod Bethune": ("Building a Better World", "0253349753"),
    "Anne Herbert": ("Random Kindness", "B01XXXXXX3"),
    "Jesmyn Ward": ("Salvage the Bones", "1608195228"),
    "Walter Dean Myers": ("Monster", "0064407331"),
    "David Mitchell": ("Cloud Atlas", "0375507256"),
    "Naomi Shihab Nye": ("Habibi", "1416924736"),
    "Catherynne M. Valente": ("The Girl Who Circumnavigated Fairyland", "1250010195"),
    "Caroline Kepnes": ("You", "1476785600"),
    "Gail Honeyman": ("Eleanor Oliphant Is Completely Fine", "0735220689"),
    "Arthur Conan Doyle": ("The Complete Sherlock Holmes", "0553328255"),
    "Elif Shafak": ("The Bastard of Istanbul", "0143112716"),
    "R.L. Stine": ("Goosebumps", "0545298385"),
    "Philip Pullman": ("The Golden Compass", "0440238137"),
    "Austin Phelps": ("The Theory of Preaching", "B00XXXXXX4"),
    "Bill Patterson": ("In Search of Wonder", "B01XXXXXX5"),
    "Paul Sweeney": ("Collected Wisdom", "B02XXXXXX6"),
    "Logan Pearsall Smith": ("Trivia", "B03XXXXXX7"),
    "Thea Dorn": ("The German House", "B04XXXXXX8"),
    "Henry Ward Beecher": ("Life Thoughts", "B05XXXXXX9"),
    "William Nicholson": ("The Wind on Fire Trilogy", "0786890894"),
    "Socrates": ("The Dialogues", "0553213717"),
    "Unknown": ("Collected Quotes", "B99XXXXXX0"),
    "Groucho Marx": ("The Groucho Letters", "0306806894"),
    "Ray Bradbury": ("Fahrenheit 451", "1451673310"),
    "Lena Dunham": ("Not That Kind of Girl", "0812985176"),
    "Stendhal": ("The Red and the Black", "0140447644"),
    "Honoré de Balzac": ("Père Goriot", "0140449221"),
    "Betty Smith": ("A Tree Grows in Brooklyn", "0062736264"),
    "Robert Louis Stevenson": ("Treasure Island", "0141321008"),
    "Benjamin Franklin": ("The Autobiography", "0486290735"),
    "Fernando Pessoa": ("The Book of Disquiet", "0141183047"),
    "Walt Disney": ("Walt Disney Biography", "1423175395"),
    "Jules Verne": ("Twenty Thousand Leagues Under the Sea", "0553213113"),
    "Maureen Corrigan": ("So We Read On", "031626297X"),
    "Arnold Lobel": ("Frog and Toad Are Friends", "0064440206"),
    "E. Nesbit": ("The Railway Children", "0140367161"),
    "Ezra Pound": ("The Cantos", "0811213269"),
    "P.J. O'Rourke": ("Parliament of Whores", "0802142180"),
    "Jane Smiley": ("A Thousand Acres", "1400033837"),
    "Thomas Aquinas": ("Summa Theologica", "1981549552"),
    "George Bernard Shaw": ("Pygmalion", "0486282228"),
    "Jacqueline Kennedy Onassis": ("In Her Own Words", "0786886676"),
    "Strickland Gillilan": ("Finnigin and His Family", "B00XXXXXX6"),
    "Victor Hugo": ("Les Misérables", "0451419677"),
    "Italo Calvino": ("If on a winter's night a traveler", "0156439611"),
    "Mary Schmich": ("Wear Sunscreen", "0312261632"),
    "Mary Wortley Montagu": ("Selected Letters", "0140437509"),
    "Emma Thompson": ("The Sense and Sensibility Screenplay", "1557043795"),
    "Aphra Behn": ("Oroonoko", "0140439889"),
    "W. Somerset Maugham": ("Of Human Bondage", "0099284960"),
    "Rainer Maria Rilke": ("Letters to a Young Poet", "0393310396"),
    "Emilie Buchwald": ("Gildaen", "1571316736"),
    "H.P. Lovecraft": ("The Call of Cthulhu", "0143129457"),
    "E.B. White": ("Charlotte's Web", "0064400557"),
    "David Levithan": ("Every Day", "0307931889"),
    "Albert Einstein": ("Relativity", "0517029618"),
    "Patrick Rothfuss": ("The Name of the Wind", "0756404746"),
    "Edgar Allan Poe": ("The Raven and Other Poems", "0486266850"),
    "Woody Allen": ("Without Feathers", "0345336976"),
    "Audrey Hepburn": ("Audrey Hepburn: An Elegant Spirit", "074325410X"),
    "Gordon B. Hinckley": ("Standing for Something", "0609609890"),
    "Holbrook Jackson": ("The Reading of Books", "B01XXXXXX7"),
    "Miguel de Cervantes Saavedra": ("Don Quixote", "0060934344"),
    "Gustave Flaubert": ("Madame Bovary", "0140449124"),
    "Wisława Szymborska": ("View with a Grain of Sand", "0156004968"),
    "David Quammen": ("The Song of the Dodo", "0684827123"),
    "Kate DiCamillo": ("The Tale of Despereaux", "0763680893"),
    "Virginia Woolf": ("Mrs Dalloway", "0156628708"),
    "Franz Kafka": ("The Metamorphosis", "0553213695"),
    "Leo Tolstoy": ("Anna Karenina", "0143035002"),
    "Jim Rohn": ("The Art of Exceptional Living", "B09N1191LJ"),
    "William Nicholson": ("Shadowlands", "0452269520"),
    "Adelise M. Cullens": ("Book of Poetry", "B08XXXXXX1"),
    "Alberto Manguel": ("A History of Reading", "0670882917"),
    "Millie Florence": ("Lost in the Library", "B07XXXXXX2"),
    "Ben Okri": ("The Famished Road", "0385425139"),
    "Nnedi Okorafor": ("Who Fears Death", "0756407303"),
    "Jesmyn Ward": ("Salvage the Bones", "1608195228"),
    "Walter Dean Myers": ("Monster", "0064407331"),
    "David Mitchell": ("Cloud Atlas", "0375507256"),
    "Naomi Shihab Nye": ("Habibi", "1416924736"),
    "Catherynne M. Valente": ("The Girl Who Circumnavigated Fairyland", "1250010195"),
    "Caroline Kepnes": ("You", "1476785600"),
    "Gail Honeyman": ("Eleanor Oliphant Is Completely Fine", "0735220689"),
    "Elif Shafak": ("The Bastard of Istanbul", "0143112716"),
    "R.L. Stine": ("Goosebumps", "0545298385"),
    "Margaret Fuller": ("Woman in the Nineteenth Century", "B00A62Y8QO"),
}

def generate_cover_url(asin):
    """Generate Amazon cover image URL from ASIN"""
    # Amazon cover pattern for small thumbnails (100px height)
    # Note: Some older ASINs might not have images, but most will work
    return f"https://m.media-amazon.com/images/P/{asin}.jpg"

def clean_author_name(author):
    """Normalize author names"""
    return author.strip()

def create_book_id(author, book_title):
    """Create a unique book ID"""
    author_slug = author.lower().replace(" ", "_").replace(".", "")
    return f"{author_slug}_{hash(book_title) % 10000:04d}"

def extract_tags(quote_text):
    """Extract relevant tags from quote text"""
    tags = set()

    keywords = {
        "reading": ["read", "reading"],
        "books": ["book", "books", "library", "libraries"],
        "life": ["life", "lives", "living"],
        "wisdom": ["wisdom", "wise", "knowledge"],
        "imagination": ["imagination", "imagine", "dream"],
        "learning": ["learn", "education", "teach"],
        "freedom": ["free", "freedom", "liberty"],
        "magic": ["magic", "magical"],
        "friendship": ["friend", "friendship"],
        "adventure": ["adventure", "journey", "travel"],
    }

    quote_lower = quote_text.lower()
    for tag, words in keywords.items():
        if any(word in quote_lower for word in words):
            tags.add(tag)

    # Ensure at least "reading" or "books" tag
    if not tags:
        tags.add("reading")

    return sorted(list(tags))[:3]  # Max 3 tags

def generate_quotes_json():
    """Generate complete quotes JSON with all metadata"""

    # Remove duplicates (by quote text)
    seen_quotes = set()
    unique_quotes = []

    for quote_text, author in QUOTES_RAW:
        # Normalize for comparison
        normalized = quote_text.strip().lower()
        if normalized not in seen_quotes:
            seen_quotes.add(normalized)
            unique_quotes.append((quote_text, author))

    print(f"Total quotes collected: {len(QUOTES_RAW)}")
    print(f"Unique quotes after deduplication: {len(unique_quotes)}")

    # Generate quote entries
    quotes = []
    for idx, (quote_text, author) in enumerate(unique_quotes, start=1):
        author = clean_author_name(author)

        # Get book and ASIN for this author
        if author in AUTHOR_BOOKS:
            book_title, asin = AUTHOR_BOOKS[author]
        else:
            # Fallback for unknown authors
            book_title = "Collected Works"
            asin = "B00XXXXXX0"

        quote_entry = {
            "id": idx,
            "text": quote_text,
            "author": author,
            "bookTitle": book_title,
            "bookId": create_book_id(author, book_title),
            "asin": asin,
            "coverImageURL": generate_cover_url(asin),
            "isActive": True,
            "tags": extract_tags(quote_text),
            "dateAdded": datetime.now().strftime("%Y-%m-%d")
        }

        quotes.append(quote_entry)

    # Create final JSON structure
    quotes_json = {
        "version": 1,
        "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
        "quotes": quotes
    }

    return quotes_json

if __name__ == "__main__":
    result = generate_quotes_json()

    # Write to file
    output_path = "/Users/joakimachren/pageinstead-swift/PageInstead/Resources/quotes.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Generated {len(result['quotes'])} quotes")
    print(f"📝 Saved to: {output_path}")
    print(f"\nSample quote:")
    print(f"  {result['quotes'][0]['text']}")
    print(f"  - {result['quotes'][0]['author']}, {result['quotes'][0]['bookTitle']}")
    print(f"  ASIN: {result['quotes'][0]['asin']}")
    print(f"  Cover: {result['quotes'][0]['coverImageURL']}")
