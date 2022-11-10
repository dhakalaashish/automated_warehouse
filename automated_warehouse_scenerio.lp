%%%%%%%%%%% Sort and object declaration : Converting from the input instance 
%%%%%%%%%%%%%%%%%%%%%%
% Defining each object
cell(C):- init(object(node,C),value(at,pair(X,Y))).
highway(C):- init(object(highway,C),value(at,pair(X,Y))).
pickingStation(P):- init(object(pickingStation,P),value(at,pair(X,Y))), init(object(node,C),value(at,pair(X,Y))).
robot(R):- init(object(robot,R),value(at,pair(X,Y))).
shelf(S):- init(object(shelf,S),value(at,pair(X,Y))).
product(PR):- init(object(product,PR),value(on,pair(S,PQ))).
order(O):- init(object(order,O),value(pickingStation,PKI)).
% Defining permanent states of static objects
cellCoordinates(C, cell(X,Y)):- init(object(node,C),value(at,pair(X,Y))).
pickingStationLocation(P,C):- init(object(pickingStation,P),value(at,pair(X,Y))), init(object(node,C),value(at,pair(X,Y))).
% Defining initial state of the dynamic objects
robotLocation(R,on(cell,C),0):- init(object(robot,R),value(at,pair(X,Y))), cellCoordinates(C,cell(X,Y)).
shelfLocation(S,on(cell,C),0):- init(object(shelf,S),value(at,pair(X,Y))), cellCoordinates(C,cell(X,Y)).
productSummary(PR,on(shelf,S),has(unit,PQ),0):- init(object(product,PR),value(on,pair(S,PQ))).
orderSummary(O,on(cell,C),with(PR,PQ),0):- init(object(order,O),value(pickingStation,PKI)), pickingStationLocation(PKI,C), init(object(order,O),value(line,pair(PR,PQ))).
% counting number of objects
numOfCols(NC):-
NC=#count{X:init(object(node,I),value(at,pair(X,Y)))}.
numOfRows(NR):-
NR=#count{Y:init(object(node,I),value(at,pair(X,Y)))}.
totalRobots(TR):-
TR=#count{I:init(object(robot,I),value(at,pair(X,Y)))}.
%%%%%%%%%%%%%%%%%%%%%% DOMAIN 
INDEPENDENT AXIOMS 
%%%%%%%%%%%%%%%%%%%%%%
%% Fluents are initially exogenous
% we don't need this cuz the initial value of fluents are 
given by the instances already
%% Actions are exogenous
% Robot can either move at most one move from the these 
{(1,0), (-1,0), (0,1), (0,-1) } 4 moves at a time, or not move 
at all
moves(1,0;-1,0;0,1;0,-1).
% Here we define the 4 kinds of actions that can take place
{robotMoves(R,moves(DX,DY),T):moves(DX,DY)}1:-
R=1..TR, totalRobots(TR), T=1..n-1.
{pickUpShelf(R,S,T):shelf(S)}1:- R=1..TR, totalRobots(TR), T=1..n-1.
{putDownShelf(R,S,T):shelf(S)}1:- R=1..TR, totalRobots(TR), T=1..n-1.
{deliveringOrder(R,O,has(S,PR,DQ),T):orderSummary(O,on(cell,C),wit
h(PR,OQ),T), productSummary(PR,on(shelf,S),has(unit,PQ),T), 
DQ=1..PQ}1:- R=1..TR, totalRobots(TR), T=1..n-1.
%% Uniqueness and existence of value constraints
%% Commonsense law of inertia
% Normally, we would have to write what choice is given 
for the next time stamp for each state and how many of 
those can be accepted for each time stamp, 
% but here, since the initial instance is already given and 
the condition for each change is also specified distinctly, 
then all we gotta do is add rules that
% specify in which conditions the states can remain constant at the next time stamp.
% if robot doesnot move then the location of robot remains 
the same
robotLocation(R,on(cell,C),T+1):- robotLocation(R,on(cell,C),T), not robotMoves(R,moves(_,_),T), 
T<n.
% if shelf is on the cell and not picked up then the location 
of shelf remains the same cell
shelfLocation(S,on(cell,C),T+1):-
shelfLocation(S,on(cell,C),T), not pickUpShelf(_,S,T), 
T<n.
% if the shelf is on the robot, and not put down, then the 
shelf remains on the robot
shelfLocation(S,on(robot,R),T+1):-
shelfLocation(S,on(robot,R),T), not putDownShelf(R,S,T), 
T<n.
% if the action of delivering doesn't take place, then the 
product and order summary doesn't change
orderSummary(O,on(cell,C),with(PR,OU),T+1):- orderSummary(O,on(cell,C),with(PR,OU),T), productSummary(PR,on(shelf,S),has(unit,PQ),T), not deliveringOrder(_,O,has(S,PR,_),T), T<n.
productSummary(PR,on(shelf,S),has(unit,PQ),T+1):-
productSummary(PR,on(shelf,S),has(unit,PQ),T), not deliveringOrder(_,_,has(S,PR,_),T), T<n.
%% State Constraints 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Robot
% A robot cannot be on two or more cells
:- 2{robotLocation(R,on(cell,C),T):cell(C)}, robot(R), 
T=1..n.
% A cell cannot have two or more robots
:- 2{robotLocation(R,on(cell,C),T):robot(R)}, cell(C), 
T=1..n.
% Robots cannot swap places with each other.
:- robotLocation(R1,on(cell,C1),T), robotLocation(R1,on(cell,C2),T+1), robotLocation(R2,on(cell,C2),T), robotLocation(R2,on(cell,C1),T+1), R1!=R2.
% A robot that is carrying a shelf does not fit under another 
shelf anymore
:- robotLocation(R,on(cell,C1),T), shelfLocation(S1,on(robot,R),T), robotMoves(R,moves(DX,DY),T), 
cellCoordinates(C1,cell(X,Y)), cellCoordinates(C2,cell(X+DX,Y+DY)), shelfLocation(S2,on(cell,C2),T). 
%% Shelf
% Shelf cannot be on the highway
:- shelfLocation(S,on(cell,C),_), highway(C).
% A shelf cannot be on two or more robots
:- 2{shelfLocation(S,on(robot,NR),T): robot(NR)}, 
shelf(S), T=1..n.
% A robot cannot have two or more shelves
:- 2{shelfLocation(S,on(robot,NR),T): shelf(S)}, robot(NR), T=1..n.
% A shelf cannot be on two or more cells
:- 2{shelfLocation(S,on(cell,C),T): cell(C)}, shelf(S), 
T=1..n.
% A cell cannot have two or more shelves
:- 2{shelfLocation(S,on(cell,C),T): shelf(S)}, cell(C), 
T=1..n.
% If a shelf is on a cell and on a robot at the same time, 
then that violates the constraint.
:- shelfLocation(S,on(cell,_),T), shelfLocation(S,on(robot,_),T).
%% Picking Station
% Picking Station cannot be a highway
:- pickingStationLocation(_,C), highway(C).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Effect and precondition of 
actions%%%%%%%%%%%%%%%%%%%%%%%
%%% Effect of action
%% Effect of moving a robot: 
% Robot can only move to C2 if (DX+X,DY+Y) represents C2 cell coordinates when (X,Y) was C1 coordinates 
and (DX,DY) it's motion.
robotLocation(R,on(cell,C2),T+1):- robotLocation(R,on(cell,C1),T), cellCoordinates(C1,cell(X,Y)), cellCoordinates(C2, cell(X+DX,Y+DY)), robotMoves(R,moves(DX,DY),T).
%% Effect of picking up a shelf
% If a robot picks up a shelf, and the shelf was on the 
node, and the robot was on the node too, then at the next 
time stamp, the shelf will be on that robot
shelfLocation(S,on(robot,R),T+1):- pickUpShelf(R,S,T), 
shelfLocation(S,on(cell,C),T), robotLocation(R,on(cell,C),T).
%% Effect of putting down a shelf
% If a robot puts down a shelf at a cell, then the shelf will 
be on that cell at the next time stamp
shelfLocation(S,on(cell,C),T+1):- putDownShelf(R,S,T), 
shelfLocation(S,on(robot,R),T), robotLocation(R,on(cell,C),T).
%% Effect of delivering a product
% Order quantity and product quantity is deducted by delivering quantity at next time-stamp, when delivering is 
done.
productSummary(PR,on(shelf,S),has(unit,PQ-DQ),T+1):-
deliveringOrder(R,O,has(S,PR,DQ),T), productSummary(PR,on(shelf,S),has(unit,PQ),T).
orderSummary(O,on(cell,C),with(PR,OU-DQ),T+1):- deliveringOrder(R,O,has(S,PR,DQ),T), orderSummary(O,on(cell,C),with(PR,OU),T).
%%% Precondition of Action
%% ROBOT
% Robot cannot move outside of the warehouse:
:- robotLocation(R,on(cell,C),T), robotMoves(R,moves(DX,DY),T), cellCoordinates(C,cell(X,Y)), X+DX<1.
:- robotLocation(R,on(cell,C),T), robotMoves(R,moves(DX,DY),T), cellCoordinates(C,cell(X,Y)), Y+DY<1.
:- robotLocation(R,on(cell,C),T), robotMoves(R,moves(DX,DY),T), cellCoordinates(C,cell(X,Y)), X+DX>NC, numOfCols(NC).
:- robotLocation(R,on(cell,C),T), robotMoves(R,moves(DX,DY),T), cellCoordinates(C,cell(X,Y)), Y+DY>NR, numOfRows(NR).
% 2 or more robots cannot pick up a single shelf
:- 2{pickUpShelf(RR,S,T): robot(RR)}, shelf(S).
% If a shelf is already on the robot, then another robot cannot pick up that shelf
:- pickUpShelf(R1,S,T), shelfLocation(S,on(robot,R2),T).
% Robot cannot pick up a shelf if it has already has a shelf 
on it, on the same time frame
:- pickUpShelf(R,S1,T), shelfLocation(S2,on(robot,R),T).
% Robot can only pick up the shelf if it is on the same cell 
that the shelf is on
:- pickUpShelf(R,S,T), shelfLocation(S,on(cell,C),T), not 
robotLocation(R,on(cell,C),T). 
%% PUTDOWNSHELF
% Robot cannot put down the shelf on a highway
:- putDownShelf(R,S,T), robotLocation(R,on(cell,C),T), 
highway(C). 
% 2 or more robots cannot put down a single shelf.
:- 2{putDownShelf(R,S,T): robot(R)}, shelf(S).
% Robot can only put down a shelf if it is carrying one.
:- putDownShelf(R,S,T), not shelfLocation(S,on(robot,R),T).
%% DELIVERING
% Robot cannot deliver if it is not on the picking station, 
i.e., the cell that the order has to be delivered on.
:- deliveringOrder(R,O,has(_,PR,_),T), orderSummary(O,on(cell,C),with(PR,_),T), not robotLocation(R,on(cell, C),T).
% Robot can only deliver if it has the shelf containing 
product
:- deliveringOrder(R,O,has(S,PR,_),T), productSummary(PR,on(shelf,S),has(unit,_),T), not shelfLocation(S,on(robot,R),T).
% Robot cannot deliver more quantity than the quantity of 
product. 
:- deliveringOrder(R,O,has(S,PR,DQ),T), productSummary(PR,on(shelf,S),has(unit,PQ),T), DQ>PQ.
% Robot cannot deliver more quantity that the quantity of 
order
:- deliveringOrder(R,O,has(S,PR,DQ),T), orderSummary(O,on(cell,C),with(PR,OQ),T), DQ>OQ.
%% OTHER 
% two "occurs" actions cannot occur at the same time
:- occurs(object(robot,R),A1,T), occurs(object(robot,R),A2,T), A1!=A2.
%%%%%%%%%%%%%%%%%%%%%%%%%% 
OUTPUT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%% converting the actions into necessary output format
occurs(object(robot,R),move(DX,DY),T):-
robotMoves(R,moves(DX,DY),T).
occurs(object(robot,R),pickup,T):-pickUpShelf(R,_,T).
occurs(object(robot,R),putdown,T):-putDownShelf(R,_,T).
occurs(object(robot,R),deliver(O,PR,DQ),T):-
deliveringOrder(R,O,has(S,PR,DQ),T).
%%%%%%%%%%%%%%%%%%%%%%% GOAL 
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Our Goal - that the order has been delivered in n time 
stamps
:- not orderSummary(O,on(cell,_),with(PR,0),n), orderSummary(O,on(cell,_),with(PR,_),0).
%% Minimizing the number of occurs or the time stamps.
timeStamps(N):-N=#count{T:occurs(O,A,T)}.
#minimize{1,O,A,T:occurs(O,A,T)}.
#minimize{T:occurs(O,A,T)}.

#show occurs/3.
#show timeStamps/1.