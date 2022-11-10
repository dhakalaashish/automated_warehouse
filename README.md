**Automated Warehouse Scenario**

**Problem Statement**

This is an attempt at the optimum solution for the challenge of Automated Warehouse Scenario. Basically, the challenge is to write a declarative program that will automate robots in the warehouse to deliver shelf containing orders to designated picking stations. Warehouse is made up of grid of cells called nodes and there are number of robots that move about vertically and horizontally in the grid. Products are kept in shelves that are scattered in the warehouse. There is also designated highway in the grid which cannot contain shelves but is made for robots (with or without shelves) to move about. Each robot can move under the shelves to pick up the shelf carrying the product, however, once a robot carries a shelf it cannot further move under another shelf. No robot can carry more than one shelf at a time and no two robots can collide while moving.

The challenge here is to have the program automate the task of delivering orders by following the mentioned and implied constraints. The program must come up with a plan to solve the task with least number of actions and with the least number of steps. I will be using the Answer Set Programming Language of Clingo to solve this challenge.

**Project Background**

Let's first understand Answer Set Programming (ASP) was used to write this program. ASP is very suitable for knowledge intensive and combinatorial search problems. Problem solving in ASP consists of presenting the given problem by sets of rules, finding the stable models (answer sets) for the program using an ASP Solver and extracting the optimal solution from the stable models.

Automated warehouse scenario's solution can be solved very efficiently using the capability of ASP as with it we can write rules that uses logic to search for most optimum set of results that takes from initial state of the problem to the required goal of the challenge. Simply put, with ASP, we can represent the knowledge and reason our way to the solution.

**Important concepts of ASP and Clingo**

Let's discuss a few important concepts of ASP and Clingo. I will use the syntax of Clingo to explain these important concepts:

**Rules**

Rules in Clingo have the form:

Assertion1 :- Assertion2, Condition1.

Basically, we use rules to represent any knowledge that we know of and to reason further about the knowledge. The rule above can be read as: if Assertion 2 is true and Condition 1 is true as well then Assertion 1 is true. When I mean true, I mean that the program's stable model will contain Assertion2 in it. In Clingo, the left of ":-" is called head while on the right is called body.

**Generating Choices with Choice Rule**

We can generate stable models with choice rule as well. Choice rule has the following form:

{generate} :- body.

Anything inside the curly braces will be either generated or not depending on the conditions in body. So, the answer set has the option to include "generate" in it or not.

**Cardinality Bounds**

When there is more than one choice that can be generated, we can limit the generation by using cardinality bounds. n{atom}m :- body.

The above rule basically means to generate at least n atoms and at most m atoms if the body's condition is satisfied or true.

**Intervals**

In Clingo, 1..4 means from the integers from 1 to 4.

**Common Sense Law of Inertia**

The program also needs to mention what happens to various states at the next time stamp when there is no action affecting that state. For instance, if a robot is on location L, at time T, where will it be at time T+1 I it does not move? To solve this, we must give a choice for the robot to be at the same location on time T+1, while mentioning the constraint that if it is at another location then it cannot be on the same location.

With these concepts laid out, let's move on to my approach of solving the Automated Warehouse Scenario Challenge.

**My Approach to Solving the Problem**

My approach to solving the Automated Warehouse Scenario problem can be divided into the following segments:

**Analyzing the Requirements and Planning**

I read the project description that was provided thoroughly to decide how to begin to solve the problem. I noted down the state predicates and action predicates needed to begin solving the problems. I planned that I needed to specify predicates that expressed the state of robot's location, shelf's location, product's summary, order's summary, and the action of robot's motion, picking up the shelf, putting down the shelf, and delivering orders, and thought about how these predicates can be used.

**Using the Given Instances**

Since, the initial state of the challenge was already given as instance files, I used those instance files to translate the input instance to necessary predicates. These instances were not only useful to define the predicates but were also important to describe the state of predicates when the time was zero. For example, below are two lines of my code that extracts the Robot's Location from the instance file.

First, extract the cell number for each coordinate in the predicate cellCoordinates:

_cellCoordinates(C, cell(X,Y)):- init(object(node,C), value(at, pair(X,Y)))._

Then, use this predicate with the input from the instance for robot's location to define the predicate robotLocation:

_robotLocation(R,on(cell,C),0):- init(object(robot,R), value(at, pair(X,Y))), cellCoordinates(C,cell(X,Y))._

Hence, I would not need to refer to the coordinates each time I am referring to the robot's location, but I can just refer to the cell number that the robot is on.

Similarly, I defined all the other predicates for the states of the program. Moreover, I also wrote rules that used the given instances to count the number of rows, number or columns and total number of robots.

**Domain Independent Axioms**

There are a few kinds of axioms in ASP that are domain independent and can used commonly in any programs. I used these in my program:

**Actions are exogenous**

These axioms use the choice rule to give an option for the stable models to choose whether the action happens or not at any time stamp. Here's how I defined this axiom for robot's motion:

_{robotMoves(R,moves(DX,DY),T):moves(DX,DY)}1:- R=1..TR, totalRobots(TR), T=1..n-1._

This above rule means that for each robot, and in each time frame, the stable model can choose for that particular robot to move or not. If it moves, then it should only move in the way the atom "moves(DX,DY)" was defined.

Similarly, I wrote similar rules for other actions: putting down shelf, picking up shelf, and delivering order.

**Common Sense Law of Inertia**

Then I wrote rules for the default states of objects saying that they won't change their state at any timeframe if the actions that affected them did not occur in the previous timeframe. For robot's location, I wrote the following commonsense law of inertia rule:

_robotLocation(R,on(cell,C),T+1):- robotLocation(R,on (cell,C),T), not robotMoves(R,moves(\_,\_),T), T\<n._

This basically means that if the robot does not move then it will not change its location.

**Writing State Constraints**

State constraints give constraints on states for robot's location, shelf's Location, and for other states. These rules define where the robot can be and cannot be, where the shelf can be and cannot be. Constraints work as filter in ASP to filter out unwanted or incorrect sets of stable models. Here's the list of rules of state constraints in plain English:

• A robot cannot be on two or more cells.

• A cell cannot have two or more robots.

• Robots cannot swap places with each other.

• A robot that is carrying a shelf does not fit under another anymore.

• Shelf cannot be on the highway.

• A shelf cannot be on two or more robots

• A robot cannot have two or more shelves

• A shelf cannot be on two or more cells

• A cell cannot have two or more shelves

• If a shelf is on a cell and on a robot at the same time, then that violates the constraint.

Please refer to the appendix to see the actual Clingo code for these rules.

**Effect of Actions**

Then, I wrote rules that define how the actions, when it occurs, changes the states. If the robot moves, then the robot's location will change in the next time stamp. If a robot picks up a shelf, then that shelf's location will be on top of the robot in the next time stamp. Similarly, if a robot puts down a shelf, then that shelf's location will be on top of the cell that it was put down on. If delivery of orders happen then the number of units of the product left and the number of units of order unfulfilled gets deducted by the number of units of the same product that was delivered.

**Preconditions of Action**

Not only do we have to write rules for the effect of actions, but we also have to write rules that describe when can and when can't an action take place. Here are the rules that I wrote (in plain English):

• Robot cannot move outside of the warehouse:

• 2 or more robots cannot pick up a single shelf

• If a shelf is already on the robot, then another robot cannot pick up that shelf.

• Robot cannot pick up a shelf if it has already had a shelf on it, on the same time stamp.

• Robot can only pick up the shelf if it is on the same cell that the shelf is on.

• Robot cannot put down the shelf on a highway

• 2 or more robots cannot put down a single shelf.

• Robot can only put down a shelf if it is carrying one.

• Robot cannot deliver if it is not on the picking station, i.e., the cell that the order has to be delivered on.

• Robot can only deliver if it has the shelf containing product.

• Robot cannot deliver more quantity of product than the quantity that the product has.

• Robot cannot deliver more quantity of a product that the quantity of order.

• Any two actions cannot be performed by a robot at the same time.

Please refer to the appendix to see the actual Clingo code for these rules.

**Converting to Necessary Output**

To make sure that the output matches the predicates seen in the project description, I introduced predicates that defined each of my actions. One of the examples is:

_occurs(object(robot,R),move(DX,DY),T):-robotMoves(R, moves(DX,DY),T)._

**Writing Goal State**

Then, I wrote rule for the project's goal. It is a form of planning query, such that, we are asking Clingo to find the appropriate sets of stable models that satisfies the goal condition. The rule is:

:- not orderSummary(O,on(cell,\_),with(PR,0),n), orderSummary(O,on(cell,\_),with(PR,\_),0).

It basically means that if the order units left for the product by the final time is not 0 then that violates the constraint. So, the program will try to get to this goal state.

**Optimizing**

We might get many answers with the rules so far, but we want to find the minimum timeframe to solve the problem, for this we ask Clingo to give us the most optimum stable model that reaches to the goal state with the minimum time stamps. We use following code for the optimization:

_#minimize{1,O,A,T:occurs(O,A,T)}._

_#minimize{T:occurs(O,A,T)}._

**Main Results and Analysis**

Five different instances were given to check the results of our program. I found the least number of time stamps required for each instance to reach the goal state. Below are the most optimal results for each instance:

**Instance 1**

occurs(object(robot,1),move(-1,0),1)

occurs(object(robot,2),move(-1,0),1)

occurs(object(robot,1),move(-1,0),2)

occurs(object(robot,2),pickup,2)

occurs(object(robot,2),move(0,1),3)

occurs(object(robot,1),pickup,3)

occurs(object(robot,2),deliver(1,3,4),4)

occurs(object(robot,1),move(-1,0),5)

occurs(object(robot,2),move(0,-1),5)

occurs(object(robot,1),deliver(1,1,1),6)

occurs(object(robot,2),putdown,6)

occurs(object(robot,1),putdown,7)

occurs(object(robot,2),move(1,0),7)

occurs(object(robot,1),move(0,-1),8)

occurs(object(robot,2),move(1,0),8)

occurs(object(robot,1),move(1,0),9)

occurs(object(robot,2),pickup,9)

occurs(object(robot,1),pickup,10)

occurs(object(robot,2),move(0,-1),10)

occurs(object(robot,1),move(1,0),11)

occurs(object(robot,2),deliver(3,4,1),11)

occurs(object(robot,1),move(0,-1),12)

occurs(object(robot,2),move(1,0),12)

occurs(object(robot,1),deliver(2,2,1),13) timeStamps(13)

**Instance 2**

occurs(object(robot,1),move(0,-1),1)

occurs(object(robot,2),move(0,1),1)

occurs(object(robot,1),move(-1,0),2)

occurs(object(robot,2),move(-1,0),3)

occurs(object(robot,1),move(1,0),4)

occurs(object(robot,1),move(0,1),5)

occurs(object(robot,2),move(0,-1),5)

occurs(object(robot,1),move(0,1),6)

occurs(object(robot,1),move(-1,0),7)

occurs(object(robot,2),move(1,0),7)

occurs(object(robot,1),move(-1,0),8)

occurs(object(robot,1),move(0,-1),9)

occurs(object(robot,2),move(1,0),9)

occurs(object(robot,1),move(-1,0),10)

occurs(object(robot,2),move(0,-1),10)

occurs(object(robot,2),pickup,2)

occurs(object(robot,1),pickup,3)

occurs(object(robot,2),pickup,8)

occurs(object(robot,2),putdown,6)

occurs(object(robot,2),deliver(1,1,1),4)

occurs(object(robot,2),deliver(2,2,1),11)

occurs(object(robot,1),deliver(1,3,2),11) timeStamps(11)

**Instance 3**

occurs(object(robot,1),move(0,-1),1)

occurs(object(robot,1),move(-1,0),2)

occurs(object(robot,1),move(0,-1),4)

occurs(object(robot,2),move(1,0),4)

occurs(object(robot,1),move(1,0),6)

occurs(object(robot,2),move(0,-1),6)

occurs(object(robot,2),pickup,2)

occurs(object(robot,1),pickup,3)

occurs(object(robot,1),deliver(2,4,1),5)

occurs(object(robot,2),deliver(1,2,1),7) timeStamps(7)

**Instance 4**

occurs(object(robot,1),move(-1,0),1)

occurs(object(robot,2),move(0,-1),1)

occurs(object(robot,1),move(0,-1),2)

occurs(object(robot,2),move(-1,0),3)

occurs(object(robot,1),move(-1,0),4)

occurs(object(robot,2),move(0,1),5)

occurs(object(robot,1),move(0,-1),6)

occurs(object(robot,2),move(0,1),6)

occurs(object(robot,1),move(1,0),7)

occurs(object(robot,2),move(1,0),7)

occurs(object(robot,2),move(-1,0),9)

occurs(object(robot,2),pickup,2)

occurs(object(robot,1),pickup,5)

occurs(object(robot,2),pickup,8)

occurs(object(robot,2),putdown,4)

occurs(object(robot,1),deliver(2,2,1),8)

occurs(object(robot,1),deliver(3,2,2),9)

occurs(object(robot,2),deliver(1,1,1),10) timeStamps(10)

**Instance 5**

occurs(object(robot,1),move(-1,0),1)

occurs(object(robot,2),move(-1,0),1)

occurs(object(robot,1),move(-1,0),2)

occurs(object(robot,2),move(0,1),3)

occurs(object(robot,1),move(-1,0),5)

occurs(object(robot,2),move(0,1),5)

occurs(object(robot,2),pickup,2)

occurs(object(robot,1),pickup,3)

occurs(object(robot,2),deliver(1,3,4),4)

occurs(object(robot,1),deliver(1,1,1),6) timeStamps(6)

It was critical to recheck my work again and again and find stable models that were optimal as I was constantly either getting no results or getting results that were not making any sense. Only by analyzing each rule again and again was I able to identify what was missing and what was creating a bug.

**Conclusion**

This was a very fun project to do. It was very interesting to see how declarative programming lets us just represent a world by writing rules that define the world and what actions can occur in that world. It was very interesting and amusing to see how the robot would move very drastically different even with a slight change in the rules. I was particularly stuck because I forgot to mention that robot should not be able to move around on those cells that have shelf when it already has a shelf on it. It was a bug that I only identified when I took went through each and every action of the robot from the results I had obtained.

I learned a lot from this project regarding declarative programming. I realized that before writing a declarative program, I need to think very analytically and critically on each and every state and action that could happen in that world and how could they interfere with each other. I am very happy with my success in completing this challenge.

**Opportunities for Future Work**

Traffic management is a huge problem in the city that I am living in. There are very narrow roads that have both ways traffic and some very wide roads that is right nearby and not properly used. I am thinking about assuming a imaginary simple world with such conditions and writing a ASP program that would find the best possible ways to manage traffic in such scenario. By, turning very busy roads that are two-ways to one way and so on. I know this would be a much grander project but my experience in solving this Automated Warehouse Scenario has given me some confidence in trying it out.

