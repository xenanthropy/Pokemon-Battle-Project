"""
This is my final project titled "Pokemon Battle"
The objective of the game is to select your pokemon (your opponent will be selected randomly by CPU)
you then battle; whoever can knock out the opponent's pokemon first wins
"""

import json
import random
import os

playerChoice = ""
opponentChoice = ""
playerStats = []
opponentStats = []
playerCurrentHP = 1
opponentCurrentHP = 1
winner = ""

def main():

    intro()
    playerPokemon = selectPokemon()
    startBattle(playerPokemon)
    results()

"""
Prints the introduction to the program and explains how the game works
"""
def intro():
    print()
    print("Welcome to Pokemon Battle! In this program, you will select a pokemon to battle with.")
    print("Your opponent will be chosen by the CPU. Whoever defeats the opposing pokemon first wins!")
    print("\nGood luck!")
    print()

"""
Asks the player to select a pokemon and returns the number they've selected 
(as an int) once a valid choice has been made
"""
def selectPokemon():

    printPokemonList()

    selectedPokemon = 0

    current_file_directory = os.path.dirname(__file__)
    json_file_path = os.path.join(current_file_directory, "pokemon.json")

    with open(json_file_path) as f:
        listOfPokemon = json.load(f)
    totalList = list(listOfPokemon.keys())

    #Makes sure the user selects a valid input between 1 and 6 
    while selectedPokemon < 1 or selectedPokemon > 6:
        selectedPokemon = int(input("Please select your pokemon by number (1-6): "))
        if(selectedPokemon < 1 or selectedPokemon > 6):
            print("Please select between 1 and 6!")
       
    print("You've selected: " + str(totalList[selectedPokemon - 1]))
    return selectedPokemon

"""
Starts the battling portion of the program. Loads in the player and the opponent's pokemons' base stats
from the pokemon.json file and passes them to the getStats() function which returns the pokemon's calculated
stats; assigns said stats to the global variables for later use. Using the 2 pokemons' speed stats, determines
which pokemon attacks first and calls the appropriate attack function
"""
def startBattle(playerPokemon):
    global playerChoice
    global opponentChoice
    global playerStats
    global opponentStats
    global playerCurrentHP
    global opponentCurrentHP
    opponent = random.randint(1,6)

    current_file_directory = os.path.dirname(__file__)
    json_file_path = os.path.join(current_file_directory, "pokemon.json")

    with open(json_file_path) as f:
        listOfPokemon = json.load(f)

    totalList = list(listOfPokemon.keys())
    playerName = str(totalList[playerPokemon - 1])
    opponentName = str(totalList[opponent - 1])
    playerChoice = playerName
    opponentChoice = opponentName

    # creates lists of player and opponents stats. In order: 
    # [Type(0), HP(1), Attack(2), Defense(3), SpAttack(4), SpDefense(5), Speed(6)]
    playerStats = getStats(playerName)
    opponentStats = getStats(opponentName)
    playerCurrentHP = playerStats[1]
    opponentCurrentHP = opponentStats[1]


    displayHealth(playerName, opponentName, playerStats[1], opponentStats[1])

    if playerStats[6] >= opponentStats[6]:
        print("Your pokemon is faster, so you attack first!")
        playerAttack()
    else:
        print("Your opponent is faster, so they attack first!")
        print()
        opponentAttack()


"""
Conducts the player's attack. Checks for various factors (accuracy, whether the attack is a critical hit, etc.)
then calculates the damage of the attack based on the pokemon's attack/defense stats; subtracts
the calculated damage from the opponent's current HP 
"""
def playerAttack():

    global winner
    global opponentCurrentHP
    
    if(playerCurrentHP > 0):
        displayHealth(playerChoice, opponentChoice, playerCurrentHP, opponentCurrentHP)
        
        move = selectMove("Player")

        current_file_directory = os.path.dirname(__file__)
        json_file_path = os.path.join(current_file_directory, "moves.json")

        with open(json_file_path) as f:
            moveDict = json.load(f)
        
        moveInfo = moveDict.get(move)

        moveType = moveInfo[0]
        moveStatus = moveInfo[1]
        movePower = int(moveInfo[2])
        moveAccuracy = int(moveInfo[3])

        print()
        print(str(playerChoice) + " uses " + str(move) + "!")
        accuracyCheck = random.randint(1,100)
        typeEffect = str(getTypeEffect(moveType, opponentStats[0]))

        # If move is going to miss, don't bother calculating damage and move on to opponent attack
        if(accuracyCheck > moveAccuracy):
            print("But it missed!")
            print("0 Damage Dealt")
            opponentAttack()

        # If move is not effective, don't bother calculating damage and move on to opponent attack
        elif(typeCalculation(moveType, opponentStats[0]) == 0):
            print(typeEffect)
            print("0 Damage Dealt")
            opponentAttack()

        else:
            damageResults = calculateDamage(moveType, moveStatus, movePower, "Player")
            if(typeEffect != ""):
                print(typeEffect)

            if(damageResults[1] > 1.0):
                print("Critical Hit!")

            print("Dealt " + str(damageResults[0]) + " damage.")
            if(opponentCurrentHP - int(damageResults[1]) < 0):
                opponentCurrentHP = 0
            else:
                opponentCurrentHP = opponentCurrentHP - int(damageResults[0])
            opponentAttack()
    else:
        winner = "Opponent"

"""
Conducts the opponent's attack. Checks for various factors (accuracy, whether the attack is a critical hit, etc.)
then calculates the damage of the attack based on the pokemon's attack/defense stats; subtracts
the calculated damage from the player's current HP 
"""
def opponentAttack():

    global winner
    global playerCurrentHP
    
    if(opponentCurrentHP > 0):       
        move = selectMove("Opponent")

        current_file_directory = os.path.dirname(__file__)
        json_file_path = os.path.join(current_file_directory, "moves.json")

        with open(json_file_path) as f:
            moveDict = json.load(f)
        moveInfo = moveDict.get(move)

        moveType = moveInfo[0]
        moveStatus = moveInfo[1]
        movePower = int(moveInfo[2])
        moveAccuracy = int(moveInfo[3])

        print()
        print(str(opponentChoice) + " uses " + str(move) + "!")
        accuracyCheck = random.randint(1,100)
        typeEffect = str(getTypeEffect(moveType, playerStats[0]))

        # If move is going to miss, don't bother calculating damage and move on to player attack
        if(accuracyCheck > moveAccuracy):
            print("But it missed!")
            print("0 Damage Dealt")
            playerAttack()

        # If move is not effective, don't bother calculating damage and move on to player attack
        elif(typeCalculation(moveType, playerStats[0]) == 0):
            print(typeEffect)
            print("0 Damage Dealt")
            playerAttack()

        else:
            damageResults = calculateDamage(moveType, moveStatus, movePower, "Opponent")
            if(typeEffect != ""):
                print(typeEffect)

            if(damageResults[1] > 1.0):
                print("Critical Hit!")

            print("Dealt " + str(damageResults[0]) + " damage.")
            if(playerCurrentHP - int(damageResults[1]) < 0):
                playerCurrentHP = 0
            else:
                playerCurrentHP = playerCurrentHP - int(damageResults[0])
            playerAttack()
    else:
        winner = "Player"


"""
Takes in multiple factors (STAB, critical chance, type advantages, etc.) in order to calculate
the damage that a certain move does against a certain pokemon
"""
def calculateDamage(moveType, moveStatus, movePower, selection):
    LEVEL = 100.0

    if(selection == "Player"):

        if(moveStatus == "Physical"):
            attack = playerStats[2]
            defense = opponentStats[3]
            defenseType = opponentStats[0]

        elif(moveStatus == "Special"):
            attack = playerStats[4]
            defense = opponentStats[5]    
            defenseType = opponentStats[0]

    if(selection == "Opponent"):

        if(moveStatus == "Physical"):
            attack = opponentStats[2]
            defense = playerStats[3]
            defenseType = playerStats[0]

        elif(moveStatus == "Special"):
            attack = opponentStats[4]
            defense = playerStats[5]
            defenseType = playerStats[0]
    
    critChance = random.randint(1,16)
    if(critChance == 1):
        critical = 1.5
    else:
        critical = 1.0
    
    randomNumber = float(float(random.randint(85,100))/100.0

    stab = 1.0
    if(selection == "Player"):
        if(moveType == playerStats[0]):
            stab = 1.5
    if(selection == "Opponent"):
        if(moveType == opponentStats[0]):
            stab = 1.5

    typeEffectiveness = float(typeCalculation(moveType, defenseType))
    
    damage = float(((((((2.0 * LEVEL) / 5.0) + 2.0) * movePower * (float(attack / defense))) / 50.0) + 2.0) * critical * randomNumber * stab * typeEffectiveness)
    return [int(damage), critical]

"""
Shows the moveset for the player's selected Pokemon. Checks which pokemon the player selected,
passes it through the "learnedMoves" json file and displays the 4 moves currently available.
Returns the player's selected move choice as a string

For the opponent - randomly selects a move out of the pokemon's movepool to use
"""
def selectMove(attacker):
    selectedMove = 0

    current_file_directory = os.path.dirname(__file__)
    json_file_path = os.path.join(current_file_directory, "learnedMoves.json")

    with open(json_file_path) as f:
        learnedMoves = json.load(f)

    if(attacker == "Player"):
        moves = list(learnedMoves.get(playerChoice))
        count = 1
        for key in moves:
            print(str(count) + ". " + str(key))    
            count += 1
        print()
        while(selectedMove < 1 or selectedMove > 4):
            selectedMove = int(input("Select a move: "))
            if (selectedMove < 1 or selectedMove > 4):
                print("please select 1 through 4!")
                print()            
        selectedMove = moves[selectedMove - 1]

    if(attacker == "Opponent"):
        moves = list(learnedMoves.get(opponentChoice))
        choice = random.randint(1,4)
        selectedMove = moves[choice - 1]

    return str(selectedMove)


"""
Prints the results of the battle.
Shows which pokemon fainted, and declares who the winner is
"""
def results():
    print()
    if(winner == "Player"):
        print(opponentChoice + " has fainted!")
    elif(winner == "Opponent"):
        print(playerChoice + " has fainted!")
    print()
    print(winner + " wins!")


"""
Returns a string based upon whether the attack was super-effective, not very effective, or had no effect
"""
def getTypeEffect(moveType, defendingType):
    result = typeCalculation(moveType, defendingType)
    if(result == 2):
        return "It's super-effective!"
    elif(result == .5):
        return "It's not very effective."
    elif(result == 0):
        return "It has no effect."
    return ""

"""
Takes in 2 inputs (type 1, and type 2) to calculate if a move is not very effective, normally effective, or super effective
depending on the type of the offense and the type of the defense
"""
def typeCalculation(attack, defend):
    if attack == "Rock" and defend == "Fire":
        return 2
    if attack == "Ground" and defend == "Grass":
        return .5
    if attack == "Ground" and defend == "Electric":
        return 2
    if attack == "Ground" and defend == "Fire":
        return 2
    if attack == "Dark" and defend == "Psychic":
        return 2
    if attack == "Dark" and defend == "Ghost":
        return 2
    if attack == "Fire" and defend == "Grass":
        return 2
    if attack == "Fire" and defend == "Fire":
        return .5
    if attack == "Psychic" and defend == "Psychic":
        return .5
    if attack == "Electric" and defend == "Grass":
        return .5
    if attack == "Electric" and defend == "Electric":
        return .5
    if attack == "Steel" and defend == "Fire":
        return .5
    if attack == "Fairy" and defend == "Fire":
        return .5
    if attack == "Bug" and defend == "Grass":
        return 2
    if attack == "Bug" and defend == "Fire":
        return .5
    if attack == "Bug" and defend == "Ghost":
        return .5
    if attack == "Bug" and defend == "Psychic":
        return 2
    if attack == "Grass" and defend == "Fire":
        return .5
    if attack == "Grass" and defend == "Grass":
        return .5
    if attack == "Ghost" and defend == "Normal":
        return 0
    if attack == "Normal" and defend == "Ghost":
        return 0
    if attack == "Ghost" and defend == "Psychic":
        return 2
    if attack == "Ghost" and defend == "Ghost":
        return 2
    return 1

"""
Displays the names and current health of both you and your opponent's pokemon
"""
def displayHealth(playerName, opponentName, playerHP, opponentHP):

    playerAllStats = getStats(playerName)
    opponentAllStats = getStats(opponentName)

    print("")
    print("------------------------------")
    print("Player")
    print(str(playerName) + " " + str(playerHP) + "/" + str(playerAllStats[1]))
    print("")
    print("Opponent")
    print(str(opponentName) + " " + str(opponentHP) + "/" + str(opponentAllStats[1]))
    print("------------------------------")
    print("")

"""
Loads the contents of pokemon.json into a dictionary (listOfPokemon) and prints the
keys of said dictionary (the pokemons' names)
"""
def printPokemonList():

    count = 0

    current_file_directory = os.path.dirname(__file__)
    json_file_path = os.path.join(current_file_directory, "pokemon.json")

    with open(json_file_path) as f:
        listOfPokemon = json.load(f)

    for key in listOfPokemon:
        count += 1
        print("(" + str(count) + ") " + str(key))

    print()

"""
Using the pokemon's base stats (from the pokemon.json dictionary), calculates the pokemon's current stats
by applying a formula using a variety of variables (as used in the actual pokemon games themselves)
"""
def getStats(name):

    IV = 31
    LEVEL = 100
    EV = 85
    NATURE = 1
    baseStats = []

    current_file_directory = os.path.dirname(__file__)
    json_file_path = os.path.join(current_file_directory, "pokemon.json")

    with open(json_file_path) as f:
        listOfPokemon = json.load(f)
    baseStats = listOfPokemon.get(name)

    pokeType = baseStats[0]
    hp = int((((2 * baseStats[1] + IV + (EV/4)) * LEVEL) / 100) + LEVEL + 10)
    attack = int(((((2 * baseStats[2] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE)
    defense = int(((((2 * baseStats[3] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE)
    spattack = int(((((2 * baseStats[4] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE)
    spdefense = int(((((2 * baseStats[5] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE)
    speed = int(((((2 * baseStats[6] + IV + (EV/4)) * LEVEL)/100)+5) * NATURE)

    stats = [pokeType, hp, attack, defense, spattack, spdefense, speed]
    return stats

if __name__ == '__main__':
    main()