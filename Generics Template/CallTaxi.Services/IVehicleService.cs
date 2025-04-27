using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using System.Threading.Tasks;

namespace CallTaxi.Services
{
    public interface IVehicleService : ICRUDService<VehicleResponse, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        Task<VehicleResponse> AcceptAsync(int id);
        Task<VehicleResponse> RejectAsync(int id);
    }
} 