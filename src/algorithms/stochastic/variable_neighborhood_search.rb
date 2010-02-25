# Variable Neighborhood Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

MAX_NO_MPROVEMENTS = 50
LOCAL_SEARCH_NO_IMPROVEMENTS = 70
NEIGHBORHOODS = 1...20
berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
 [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
 [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
 [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
 [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],
 [875,920],[700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],
 [595,360],[1340,725],[1740,245]]

def euc_2d(c1, c2)
  Math::sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def random_permutation(cities)
  perm = Array.new(cities.length){|i|i}
  for i in 0...perm.length
    r = rand(perm.length-i) + i
    perm[r], perm[i] = perm[i], perm[r]
  end
  return perm
end

def stochastic_two_opt!(perm)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def cost(permutation, cities)
  distance =0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def local_search(best, cities, maxNoImprovements, neighbourhood)
  noImprovements = 0
  begin
    candidate = {}
    candidate[:vector] = Array.new(best[:vector])
    neighbourhood.times{stochastic_two_opt!(candidate[:vector])}
    candidate[:cost] = cost(candidate[:vector], cities)
    if candidate[:cost] < best[:cost]
      noImprovements, best = 0, candidate
    else
      noImprovements += 1      
    end
  end until noImprovements >= maxNoImprovements
  return best
end

def search(cities, neighbourhoods, maxNoImprovements, maxNoImprovementsLS)
  best = {}
  best[:vector] = random_permutation(cities)
  best[:cost] = cost(best[:vector], cities)
  iter, noImprovements = 0, 0
  begin
    neighbourhoods.each do |neighbourhood|
      candidate = {}
      candidate[:vector] = Array.new(best[:vector])      
      neighbourhood.times{stochastic_two_opt!(candidate[:vector])}
      candidate[:cost] = cost(candidate[:vector], cities)
      candidate = local_search(candidate, cities, maxNoImprovementsLS, neighbourhood)      
      puts " > iteration #{(iter+1)}, neighborhood=#{neighbourhood}, best: c=#{best[:cost]}"
      iter += 1
      if(candidate[:cost] < best[:cost])
        best = candidate
        noImprovements = 0
        puts "New best, restarting neighbourhood search."
        break
      else
        noImprovements += 1
      end
    end  
  end until noImprovements >= maxNoImprovements
  return best
end

best = search(berlin52, NEIGHBORHOODS, MAX_NO_MPROVEMENTS, LOCAL_SEARCH_NO_IMPROVEMENTS)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"