# 1. Total = electricty_consumption * number_of_residences
# 1. Total = electricty_consumption * number_of_residences
# 2.3 Verdeling cooking
#     3.09% -> inductie, halogeen, resistive
#              \                           /
#                         28.3%
#
# 2.3.1 Tel je bij elkaar op 28.3% 71.7% (gas) -> bepaald demand gas mee
# 2.4. Cooling:
#    "Kou onttrokken aan de omgeving" per residence
#    "schalen naar hoeveelheid huishoudens"
#    hp_ground (FD) = (1909 / HHnl * number_of_residences) / eff -1
#
#    7.22% van het totaal - hp_ground_demand = airco
#
# 2.5 Hot water
# 2.5.1 Heat pump ground
#       - number_of_heat_pumps = x% * number_of_residences
#       - total_final_demand = Demand of heat pump * number_of_heat_pumps
# 2.5.2 Heat pump air
#       *
# 2.5.3 Electrische boiler
#       (5.15% * Ec) - heat_pump_air_demand - heat_pump_ground_demand
# 2.5.4 cv_ketel = gas * 1/5 -> na koken (gas_consumption - koken gas)
# 2.6 Space heating
#  same beef 4/5 na koken
#
# For all 2.*
#
# Van useful_demand = final_demand * effiency
#
# ----
#
# 3 Transport
#     (total_demand_of_cars_nl / number_of_cars_nl) * number_of_cars
#     of
#     (total_demand_current / number_of_cars_current) * new_number_of_cars
#
# 4. Energy
# 5. Nullen van bepaalde initializers
#

