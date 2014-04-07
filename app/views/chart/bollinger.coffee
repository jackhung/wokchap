module.exports = class Bollinger
  constructor: ->
    @prices = []
    @periods = 20
    @multiple = 2
    @sum = 0.0
    @sumSquared = 0.0
    @isFull = false
  add: (n) ->
    @prices.push(n)
    @sum += n;
    @sumSquared += n * n;
    if (@prices.length > @periods) 
      oldest = @prices.shift();
      @sum -= oldest;
      @sumSquared -= oldest * oldest;
      @isFull = true;
  mean: ->
    @sum / @periods;
  stdDev: ->
    num = @periods * @sumSquared - (@sum * @sum);
    denom = @periods * (@periods - 1);
    Math.sqrt(num / denom);
  valUpper: ->
    @mean() + @stdDev() * @multiple;
  valLower: ->
    @mean() - @stdDev() * @multiple;
  calculate: (priceData) ->
    up = []
    low = []
    m = []
    
    for r, idx in priceData
      @add r[4]
      if @isFull
        up.push @valUpper()
        low.push @valLower()
        m.push @mean()
      else
        up.push null
        low.push null
        m.push null
    {bolMA: m, bolUP: up, bolLO: low}
  clear: ->
    @prices = []
    @sum = 0.0
    @sumSquared = 0.0
    @isFull = false