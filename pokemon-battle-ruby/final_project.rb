#
#This is my final project titled "Pokemon Battle"
#The objective of the game is to select your pokemon (your opponent will be selected randomly by CPU)
#you then battle; whoever can knock out the opponent's pokemon first wins
#

require 'json'

$playerChoice = ""
$opponentChoice = ""
$playerStats = []
$opponentStats = []
$playerCurrentHP = 1
$opponentCurrentHP = 1
$winner = ""
IV = 31
LEVEL = 100
EV = 85
NATURE = 1
LEVEL = 100.0


def main()
    intro()
    playerPokemon = selectPokemon()
    startBattle(playerPokemon)
    results()
end


#Prints the introduction to the program and explains how the game works
def intro()
    puts ""
    puts("Welcome to Pokemon Battle! In this program, you will select a pokemon to battle with.")
    puts("Your opponent will be chosen by the CPU. Whoever defeats the opposing pokemon first wins!")
    puts("\nGood luck!")
    puts ""
end

#
#Asks the player to select a pokemon and returns the number they've selected 
#(as an int) once a valid choice has been made
#
def selectPokemon()

    printPokemonList()

    selectedPokemon = 0
    
    pokemonFile = File.read('pokemon.json')
    listOfPokemon = JSON.parse(pokemonFile)
    totalList = listOfPokemon.keys
    
    #Makes sure the user selects a valid input between 1 and 6 
    while(selectedPokemon < 1 || selectedPokemon > 6)
        puts "Please select your pokemon by number (1-6): "
        selectedPokemon = gets.chomp.to_i
        if(selectedPokemon < 1 or selectedPokemon > 6)
            puts("Please select between 1 and 6!")
        end
    end
    puts "You've selected: " + (totalList[selectedPokemon - 1]).to_s
    return selectedPokemon

end

#
#Starts the battling portion of the program. Loads in the player and the opponent's pokemons' base stats
#from the pokemon.json file and passes them to the getStats() function which returns the pokemon's calculated
#stats; assigns said stats to the global variables for later use. Using the 2 pokemons' speed stats, determines
#which pokemon attacks first and calls the appropriate attack function
#
def startBattle(playerPokemon)
    
    opponent = rand(1..6)

    pokemonFile = File.read('pokemon.json')
    listOfPokemon = JSON.parse(pokemonFile)
    totalList = listOfPokemon.keys
  
    playerName = (totalList[playerPokemon - 1]).to_s
    opponentName = (totalList[opponent - 1]).to_s
    $playerChoice = playerName
    $opponentChoice = opponentName

    # creates lists of player and opponents stats. In order: 
    # [Type(0), HP(1), Attack(2), Defense(3), SpAttack(4), SpDefense(5), Speed(6)]
    $playerStats = getStats(playerName)
    $opponentStats = getStats(opponentName)
    $playerCurrentHP = $playerStats[1]
    $opponentCurrentHP = $opponentStats[1]


    displayHealth(playerName, opponentName, $playerStats[1], $opponentStats[1])

    if $playerStats[6] >= $opponentStats[6]
        puts("Your pokemon is faster, so you attack first!")
        playerAttack()
    else
        puts("Your opponent is faster, so they attack first!")
        puts ""
        opponentAttack()
    end
end

#
#Conducts the player's attack. Checks for various factors (accuracy, whether the attack is a critical hit, etc.)
#then calculates the damage of the attack based on the pokemon's attack/defense stats; subtracts
#the calculated damage from the opponent's current HP 
#
def playerAttack()

    if($playerCurrentHP > 0)
        displayHealth($playerChoice, $opponentChoice, $playerCurrentHP, $opponentCurrentHP)
        
        move = selectMove("Player")

        pokemonFile = File.read('moves.json')
        moveDict = JSON.parse(pokemonFile)

        #moveInfo = moveDict.get(move)
        moveInfo = moveDict[move]

        moveType = moveInfo[0]
        moveStatus = moveInfo[1]
        movePower = moveInfo[2].to_i
        moveAccuracy = moveInfo[3].to_i

        puts ""
        puts($playerChoice.to_s + " uses " + move.to_s + "!")
        accuracyCheck = rand(1..100)
        typeEffect = (getTypeEffect(moveType, $opponentStats[0])).to_s

        # If move is going to miss, don't bother calculating damage and move on to opponent attack
        if(accuracyCheck > moveAccuracy)
            puts("But it missed!")
            puts("0 Damage Dealt")
            opponentAttack()
        # If move is not effective, don't bother calculating damage and move on to opponent attack
        elsif(typeCalculation(moveType, $opponentStats[0]) == 0)
            puts(typeEffect)
            puts("0 Damage Dealt")
            opponentAttack()

        else
            damageResults = calculateDamage(moveType, moveStatus, movePower, "Player")
            if(typeEffect != "")
                puts(typeEffect)
            end
            if(damageResults[1] > 1.0)
                puts("Critical Hit!")
            end
            puts("Dealt " + (damageResults[0]).to_s + " damage.")
            if($opponentCurrentHP - (damageResults[1]).to_i < 0)
                $opponentCurrentHP = 0
            else
                $opponentCurrentHP = $opponentCurrentHP - (damageResults[0]).to_i
            end
            opponentAttack()
        end
    else
        $winner = "Opponent"
    end
end

#
#Conducts the opponent's attack. Checks for various factors (accuracy, whether the attack is a critical hit, etc.)
#then calculates the damage of the attack based on the pokemon's attack/defense stats; subtracts
#the calculated damage from the player's current HP 
#
def opponentAttack()
    
    if($opponentCurrentHP > 0)
             
        move = selectMove("Opponent")
        
        pokemonFile = File.read('moves.json')
        moveDict = JSON.parse(pokemonFile)

        moveInfo = moveDict[move]

        moveType = moveInfo[0]
        moveStatus = moveInfo[1]
        movePower = (moveInfo[2]).to_i
        moveAccuracy = (moveInfo[3]).to_i

        puts ""
        puts(($opponentChoice).to_s + " uses " + (move).to_s + "!")
        accuracyCheck = rand(1..100)
        typeEffect = (getTypeEffect(moveType, $playerStats[0])).to_s

        # If move is going to miss, don't bother calculating damage and move on to player attack
        if(accuracyCheck > moveAccuracy)
            puts("But it missed!")
            puts("0 Damage Dealt")
            playerAttack()

        # If move is not effective, don't bother calculating damage and move on to player attack
        elsif(typeCalculation(moveType, $playerStats[0]) == 0)
            puts(typeEffect)
            puts("0 Damage Dealt")
            playerAttack()

        else
            damageResults = calculateDamage(moveType, moveStatus, movePower, "Opponent")
            if(typeEffect != "")
                puts(typeEffect)
            end
            if(damageResults[1] > 1.0)
                puts("Critical Hit!")
            end
            puts("Dealt " + (damageResults[0]).to_s + " damage.")
            if($playerCurrentHP - (damageResults[1]).to_i < 0)
                $playerCurrentHP = 0
            else
                $playerCurrentHP = $playerCurrentHP - (damageResults[0]).to_i
            end
            playerAttack()
        end
    else
        $winner = "Player"
    end
end

#
#Takes in multiple factors (STAB, critical chance, type advantages, etc.) in order to calculate
#the damage that a certain move does against a certain pokemon
#
def calculateDamage(moveType, moveStatus, movePower, selection)
    

    if(selection == "Player")

        if(moveStatus == "Physical")
            attack = $playerStats[2]
            defense = $opponentStats[3]
            defenseType = $opponentStats[0]

        elsif(moveStatus == "Special")
            attack = $playerStats[4]
            defense = $opponentStats[5]    
            defenseType = $opponentStats[0]
        end
    end

    if(selection == "Opponent")

        if(moveStatus == "Physical")
            attack = $opponentStats[2]
            defense = $playerStats[3]
            defenseType = $playerStats[0]

        elsif(moveStatus == "Special")
            attack = $opponentStats[4]
            defense = $playerStats[5]
            defenseType = $playerStats[0]
        end
    end

    critChance = rand(1..16)
    if(critChance == 1)
        critical = 1.5
    else
        critical = 1.0
    end

    randomNumber = ((rand(85..100).to_f)/100.0).to_f

    stab = 1.0
    if(selection == "Player")
        if(moveType == $playerStats[0])
            stab = 1.5
        end
    end
    if(selection == "Opponent")
        if(moveType == $opponentStats[0])
            stab = 1.5
        end
    end
    typeEffectiveness = (typeCalculation(moveType, defenseType)).to_f
    
    damage = (((((((2.0 * LEVEL) / 5.0) + 2.0) * movePower * ((attack / defense).to_f)) / 50.0) + 2.0) * critical * randomNumber * stab * typeEffectiveness).to_f
    return [(damage).to_i, critical]
end

#
#Shows the moveset for the player's selected Pokemon. Checks which pokemon the player selected,
#passes it through the "learnedMoves" json file and displays the 4 moves currently available.
#Returns the player's selected move choice as a string
#
#For the opponent - randomly selects a move out of the pokemon's movepool to use
#
def selectMove(attacker)
    selectedMove = 0

    pokemonFile = File.read('learnedMoves.json')
    learnedMoves = JSON.parse(pokemonFile)

    if(attacker == "Player")
        moves = learnedMoves[$playerChoice]
        count = 1
        
        moves.each do |key|
            puts count.to_s + ". " + key.to_s
            count += 1
        end
    
        puts ""
        while(selectedMove < 1 || selectedMove > 4)
            puts "Select a move: "
            selectedMove = gets.chomp.to_i
            if (selectedMove < 1 || selectedMove > 4)
                puts("please select 1 through 4!")
                puts ""
            end
        end            
        selectedMove = moves[selectedMove - 1]
    end
    if(attacker == "Opponent")
        moves = learnedMoves[$opponentChoice]
        srand
        choice = rand(1..4)
        selectedMove = moves[choice - 1]
    end
    return (selectedMove).to_s
end
#
#Prints the results of the battle.
#Shows which pokemon fainted, and declares who the winner is
#
def results()
    puts ""
    if($winner == "Player")
        puts($opponentChoice + " has fainted!")
    elsif($winner == "Opponent")
        puts($playerChoice + " has fainted!")
    end
    puts ""
    puts($winner + " wins!")
end

#
#Returns a string based upon whether the attack was super-effective, not very effective, or had no effect
#
def getTypeEffect(moveType, defendingType)
    result = typeCalculation(moveType, defendingType)
    if(result == 2)
        return "It's super-effective!"
    elsif(result == 0.5)
        return "It's not very effective."
    elsif(result == 0)
        return "It has no effect."
    end
    return ""
end

#
#Takes in 2 inputs (type 1, and type 2) to calculate if a move is not very effective, normally effective, or super effective
#depending on the type of the offense and the type of the defense
#
def typeCalculation(attack, defend)
    if attack == "Rock" && defend == "Fire"
        return 2
    end
    if attack == "Ground" && defend == "Grass"
        return 0.5
    end
    if attack == "Ground" && defend == "Electric"
        return 2
    end
    if attack == "Ground" && defend == "Fire"
        return 2
    end
    if attack == "Dark" && defend == "Psychic"
        return 2
    end
    if attack == "Dark" && defend == "Ghost"
        return 2
    end
    if attack == "Fire" && defend == "Grass"
        return 2
    end
    if attack == "Fire" && defend == "Fire"
        return 0.5
    end
    if attack == "Psychic" && defend == "Psychic"
        return 0.5
    end
    if attack == "Electric" && defend == "Grass"
        return 0.5
    end
    if attack == "Electric" && defend == "Electric"
        return 0.5
    end
    if attack == "Steel" && defend == "Fire"
        return 0.5
    end
    if attack == "Fairy" && defend == "Fire"
        return 0.5
    end
    if attack == "Bug" && defend == "Grass"
        return 2
    end
    if attack == "Bug" && defend == "Fire"
        return 0.5
    end
    if attack == "Bug" && defend == "Ghost"
        return 0.5
    end
    if attack == "Bug" && defend == "Psychic"
        return 2
    end
    if attack == "Grass" && defend == "Fire"
        return 0.5
    end
    if attack == "Grass" && defend == "Grass"
        return 0.5
    end
    if attack == "Ghost" && defend == "Normal"
        return 0
    end
    if attack == "Normal" && defend == "Ghost"
        return 0
    end
    if attack == "Ghost" && defend == "Psychic"
        return 2
    end
    if attack == "Ghost" && defend == "Ghost"
        return 2
    end
    return 1
end

#
#Displays the names and current health of both you and your opponent's pokemon
#
def displayHealth(playerName, opponentName, playerHP, opponentHP)

    playerAllStats = getStats(playerName)
    opponentAllStats = getStats(opponentName)

    puts ""
    puts("------------------------------")
    puts("Player")
    puts(playerName.to_s + " " + playerHP.to_s + "/" + (playerAllStats[1]).to_s)
    puts ""
    puts("Opponent")
    puts(opponentName.to_s + " " + opponentHP.to_s + "/" + (opponentAllStats[1]).to_s)
    puts("------------------------------")
    puts ""
end

#
#Loads the contents of pokemon.json into a dictionary (listOfPokemon) and prints the
#keys of said dictionary (the pokemons' names)
#
def printPokemonList()

    count = 0

    pokemonFile = File.read('pokemon.json')
    listOfPokemon = JSON.parse(pokemonFile)
    pokemonArray = listOfPokemon.keys
    pokemonArray.each do |key|
        count += 1
        puts("(" + count.to_s + ") " + key.to_s)
    end
    puts ""
end

#
#Using the pokemon's base stats (from the pokemon.json dictionary), calculates the pokemon's current stats
#by applying a formula using a variety of variables (as used in the actual pokemon games themselves)
#
def getStats(name)


    baseStats = []

    pokemonFile = File.read('pokemon.json')
    listOfPokemon = JSON.parse(pokemonFile)
    baseStats = listOfPokemon[name]


    pokeType = baseStats[0]
    hp = ((((2 * baseStats[1] + IV + (EV/4)) * LEVEL) / 100) + LEVEL + 10).to_i
    attack = (((((2 * baseStats[2] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE).to_i
    defense = (((((2 * baseStats[3] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE).to_i
    spattack = (((((2 * baseStats[4] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE).to_i
    spdefense = (((((2 * baseStats[5] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE).to_i
    speed = (((((2 * baseStats[6] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE).to_i

    stats = [pokeType, hp, attack, defense, spattack, spdefense, speed]
    return stats
end

main