using CallTaxi.Model;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Responses;
using CallTaxi.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using CallTaxi.Model.Requests;

namespace CallTaxi.WebAPI.Controllers
{
    public class ProductController : BaseCRUDController<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        public ProductController(IProductService service) : base(service)
        {
        }
    }
}
