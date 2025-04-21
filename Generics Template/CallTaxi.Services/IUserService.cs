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
    public interface IUserService
    {
        Task<List<UserResponse>> GetAsync(UserSearchObject search);
        Task<UserResponse?> GetByIdAsync(int id);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
} 