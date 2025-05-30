using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;

namespace CallTaxi.Services.Interfaces
{
    public interface IBrandService : ICRUDService<BrandResponse, BrandSearchObject, BrandUpsertRequest, BrandUpsertRequest>
    {
    }
}