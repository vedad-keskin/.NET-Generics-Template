using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Requests;
using CallTaxi.Services.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace CallTaxi.Services
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request);
        Task<T?> UpdateAsync(int id, TUpdate request);
        Task<bool> DeleteAsync(int id);
    }
} 