ig.drawTemperatures!
switch window.location.hash
| '#pankrac'
  d3.select ig.containers.base .append \div
    ..attr \class "year-part pankrac"
    ..html "Pankrác, Servác a Bonifác<br>12., 13. a 14. května"

