n_resources = input("Input n resources that would be available fro Team Lead: ")
list_resources = list(range(1, int(n_resources)+1))
team_lead1 = [ int(x) for x in input("Input team lead 1 preferences (seperated by comma): ").split(",")]
team_lead2 = [ int(x) for x in input("Input team lead 2 preferences (seperated by comma): ").split(",")]
team_lead1_resources = []
team_lead2_resources = []

def resource_allocation(requested_resources):
    
    try:
        if requested_resources in list_resources:
            list_resources.remove(requested_resources)
            return requested_resources
        else:

            alternative_resource = min(list_resources)
            list_resources.remove(min(list_resources))
            print("Your requested resource unavailable, here's the smallest resource = " + str(alternative_resource) + "\n")
            return alternative_resource
    except IndexError:
        print("Resource all alocated, exiting")
        exit
    
def request_resource():
    i = 0
    while i < len(team_lead1):
        team_lead1_resources.append(resource_allocation(team_lead1[i]))
        team_lead2_resources.append(resource_allocation(team_lead2[i]))
        print("Current available resource = " + str(list_resources))
        print("Team Lead 1 = " + str(team_lead1_resources))
        print("Team Lead 2 = " + str(team_lead2_resources))
        print("===============================================\n")
        i+=1
    print("Resource all alocated, exiting")

def main():
    request_resource()

if __name__ ==  "__main__":
    main()
