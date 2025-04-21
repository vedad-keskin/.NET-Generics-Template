using CallTaxi.Model;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Responses;
using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CallTaxi.Model.Requests;
using MapsterMapper;
namespace CallTaxi.Services
{
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Database.Product, ProductInsertRequest, ProductUpdateRequest>, IProductService
    {
        public ProductService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
