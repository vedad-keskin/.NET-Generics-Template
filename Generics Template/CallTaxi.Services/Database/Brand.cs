﻿using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Services.Database
{
    public class Brand
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; }

        //public byte[]? Logo { get; set; }
    }
}
