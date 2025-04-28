using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using CallTaxi.Model.Responses;
using CallTaxi.Model.Requests;
using CallTaxi.Model.SearchObjects;
using System.Linq;
using System;
using MapsterMapper;
using CallTaxi.Model;
using Microsoft.Extensions.DependencyInjection;

namespace CallTaxi.Services.VehicleStateMachine
{
   public class BaseVehicleState
   {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly CallTaxiDbContext _context;
        protected readonly IMapper _mapper;

        public BaseVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }
        public virtual async Task<VehicleResponse> CreateAsync(VehicleInsertRequest request)
        {
                throw new UserException("Not allowed in current state");
        }

        public virtual async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
                throw new UserException("Not allowed in current state");
        }
        public virtual async Task<bool> DeleteAsync(int id)
        {
                throw new UserException("Not allowed in current state");
        }
        
        public virtual async Task<VehicleResponse> AcceptAsync(int id)
        {
                throw new UserException("Not allowed in current state");
        }

        public virtual async Task<VehicleResponse> RejectAsync(int id)
        {
                throw new UserException("Not allowed in current state");
        }

        public BaseVehicleState GetProductState(string stateName) {
            switch (stateName)
            {
                case "Initial":
                    return _serviceProvider.GetService<InitialVehicleState>();
                case "Pending":
                    return _serviceProvider.GetService<PendingVehicleState>();
                case "Accepted":
                    return _serviceProvider.GetService<AcceptedVehicleState>();
                case "Rejected":
                    return _serviceProvider.GetService<RejectedVehicleState>();

                default:
                    throw new Exception($"State {stateName} not defined");
            }
        }
   }
} 